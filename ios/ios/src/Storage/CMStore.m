//
//  CMStore.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStore.h"

#import "CMObjectDecoder.h"
#import "CMObjectEncoder.h"
#import "CMObjectSerialization.h"
#import "CMAPICredentials.h"

#define _CMAssertAPICredentialsInitialized NSAssert([[CMAPICredentials sharedInstance] apiKey] != nil && [[[CMAPICredentials sharedInstance] apiKey] length] > 0 && [[CMAPICredentials sharedInstance] appKey] != nil && [[[CMAPICredentials sharedInstance] appKey] length] > 0, @"The CMAPICredentials singleton must be initialized before using a CloudMine Store")

#define _CMAssertUserConfigured NSAssert(user, @"You must set the CMUser for this store in order to query for a user's objects")

#define _CMUserOrNil (userLevel ? user : nil)

@interface CMStore (Private)
- (void)_allObjects:(CMStoreObjectCallback)callback userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options;
- (void)_allObjects:(CMStoreObjectCallback)callback ofType:(NSString *)type userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options;
- (void)_objectsWithKeys:(NSArray *)keys callback:(CMStoreObjectCallback)callback userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options;
- (void)_searchObjects:(CMStoreObjectCallback)callback query:(NSString *)query userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options;
- (void)cacheObjectsInMemory:(NSArray *)objects atUserLevel:(BOOL)userLevel;
@end

@implementation CMStore
@synthesize webService;
@synthesize user;

#pragma mark - Initializers

+ (CMStore *)store {
    return [[self alloc] init];
}

- (id)init {
    return [self initWithUser:nil];
}

- (id)initWithUser:(CMUser *)theUser {
    if (self = [super init]) {
        self.webService = [[CMWebService alloc] init];
        self.user = theUser;
        _cachedAppObjects = [[NSMutableSet alloc] init];
        _cachedUserObjects = theUser ? [[NSMutableSet alloc] init] : nil;
    }
    return self;
}

- (void)setUser:(CMUser *)theUser {
    if (_cachedUserObjects) {
        [_cachedUserObjects removeAllObjects];
    } else {
        _cachedUserObjects = [[NSMutableSet alloc] init];
    }
    user = theUser;
}

#pragma mark - Object retrieval

- (void)allObjects:(CMStoreObjectCallback)callback additionalOptions:(CMStoreOptions *)options {    
    [self _allObjects:callback userLevel:NO additionalOptions:options];
}

- (void)allUserObjects:(CMStoreObjectCallback)callback additionalOptions:(CMStoreOptions *)options {
    _CMAssertUserConfigured;
    
    [self _allObjects:callback userLevel:YES additionalOptions:options];
}

- (void)_allObjects:(CMStoreObjectCallback)callback userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options {
    [self _objectsWithKeys:nil callback:callback userLevel:userLevel additionalOptions:options];
}

- (void)objectsWithKeys:(NSArray *)keys callback:(CMStoreObjectCallback)callback additionalOptions:(CMStoreOptions *)options {
    [self _objectsWithKeys:keys callback:callback userLevel:NO additionalOptions:options];
}

- (void)userObjectsWithKeys:(NSArray *)keys callback:(CMStoreObjectCallback)callback additionalOptions:(CMStoreOptions *)options {
    _CMAssertUserConfigured;
    
    [self _objectsWithKeys:keys callback:callback userLevel:YES additionalOptions:options];
}
- (void)_objectsWithKeys:(NSArray *)keys callback:(CMStoreObjectCallback)callback userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options {
    NSParameterAssert(callback);
    _CMAssertAPICredentialsInitialized;
    
    __weak CMStore *blockSelf = self;
    [webService getValuesForKeys:keys
              serverSideFunction:options.serverSideFunction
                   pagingOptions:options.pagingDescriptor 
                            user:_CMUserOrNil
                  successHandler:^(NSDictionary *results, NSDictionary *errors) {
                      NSArray *objects = [CMObjectDecoder decodeObjects:results];
                      [blockSelf cacheObjectsInMemory:objects atUserLevel:userLevel];
                      callback(objects);
                  } errorHandler:^(NSError *error) {
                      NSLog(@"Error occurred during request: %@", [error description]);
                      callback(nil);
                  }
     ];
}

#pragma mark Object querying by type

- (void)allObjects:(CMStoreObjectCallback)callback ofType:(NSString *)type additionalOptions:(CMStoreOptions *)options {
    [self _allObjects:callback userLevel:NO additionalOptions:options];
}

- (void)allUserObjects:(CMStoreObjectCallback)callback ofType:(NSString *)type additionalOptions:(CMStoreOptions *)options {
    _CMAssertUserConfigured;
    
    [self _allObjects:callback userLevel:YES additionalOptions:options];
}

- (void)_allObjects:(CMStoreObjectCallback)callback ofType:(NSString *)type userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options {
    NSParameterAssert(callback);
    NSParameterAssert(type);
    _CMAssertAPICredentialsInitialized;
    
    [self _searchObjects:callback 
                   query:[NSString stringWithFormat:@"[%@ = \"%@\"]", CMInternalTypeStorageKey, type]
               userLevel:userLevel
       additionalOptions:options];
}

#pragma mark General object querying

- (void)searchObjects:(CMStoreObjectCallback)callback query:(NSString *)query additionalOptions:(CMStoreOptions *)options {
    [self _searchObjects:callback query:query userLevel:NO additionalOptions:options];
}

- (void)searchUserObjects:(CMStoreObjectCallback)callback query:(NSString *)query additionalOptions:(CMStoreOptions *)options {
    _CMAssertUserConfigured;
    
    [self _searchObjects:callback query:query userLevel:YES additionalOptions:options];
}

- (void)_searchObjects:(CMStoreObjectCallback)callback query:(NSString *)query userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options {
    NSParameterAssert(callback);
    _CMAssertAPICredentialsInitialized;
    
    if (!query || [query length] == 0) {
        NSLog(@"No query provided, so executing standard all-object retrieval");
        return [self _allObjects:callback userLevel:userLevel additionalOptions:options];
    }
    
    __weak CMStore *blockSelf = self;
    [webService searchValuesFor:query
             serverSideFunction:options.serverSideFunction
                  pagingOptions:options.pagingDescriptor 
                           user:_CMUserOrNil
                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                     NSArray *objects = [CMObjectDecoder decodeObjects:results];
                     [blockSelf cacheObjectsInMemory:objects atUserLevel:userLevel];
                     callback(objects);
                 } errorHandler:^(NSError *error) {
                     NSLog(@"Error occurred during request: %@", [error description]);
                     callback(nil);
                 }
     ];
}

#pragma mark - In-memory caching

- (void)cacheObjectsInMemory:(NSArray *)objects atUserLevel:(BOOL)userLevel {
    NSAssert(userLevel ? (user != nil) : true, @"Failed trying to cache remote objects in-memory for user when user is not configured (%@)", self);
    
    if (userLevel) {
        [_cachedUserObjects addObjectsFromArray:objects];
    } else {
        [_cachedAppObjects addObjectsFromArray:objects];
    }
}

@end
