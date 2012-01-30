//
//  CMStore.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStore.h"
#import <objc/runtime.h>

#import "CMObjectDecoder.h"
#import "CMObjectEncoder.h"
#import "CMObjectSerialization.h"
#import "CMAPICredentials.h"
#import "CMObject.h"

#define _CMAssertAPICredentialsInitialized NSAssert([[CMAPICredentials sharedInstance] apiKey] != nil && [[[CMAPICredentials sharedInstance] apiKey] length] > 0 && [[CMAPICredentials sharedInstance] appKey] != nil && [[[CMAPICredentials sharedInstance] appKey] length] > 0, @"The CMAPICredentials singleton must be initialized before using a CloudMine Store")

#define _CMAssertUserConfigured NSAssert(user, @"You must set the CMUser for this store in order to query for a user's objects")

#define _CMUserOrNil (userLevel ? user : nil)

// Notification strings
NSString * const CMStoreObjectDeletedNotification = @"CMStoreObjectDeletedNotification";

@interface CMStore (Private)
- (void)_allObjects:(CMStoreObjectFetchCallback)callback userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options;
- (void)_allObjects:(CMStoreObjectFetchCallback)callback ofType:(Class)klass userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options;
- (void)_objectsWithKeys:(NSArray *)keys callback:(CMStoreObjectFetchCallback)callback userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options;
- (void)_searchObjects:(CMStoreObjectFetchCallback)callback query:(NSString *)query userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options;
- (void)_fileWithName:(NSString *)name userLevel:(BOOL)userLevel callback:(CMStoreFileFetchCallback)callback;
- (void)_saveObjects:(NSArray *)objects userLevel:(BOOL)userLevel callback:(CMStoreUploadCallback)callback;
- (void)_deleteObjects:(NSArray *)objects userLevel:(BOOL)userLevel callback:(CMStoreDeleteCallback)callback;
- (void)cacheObjectsInMemory:(NSArray *)objects atUserLevel:(BOOL)userLevel;
@end

@implementation CMStore
@synthesize webService;
@synthesize user;
@synthesize lastError;

#pragma mark - Initializers

+ (CMStore *)store {
    return [[CMStore alloc] init];
}

+ (CMStore *)storeWithUser:(CMUser *)theUser {
    return [[CMStore alloc] initWithUser:theUser];
}

- (id)init {
    return [self initWithUser:nil];
}

- (id)initWithUser:(CMUser *)theUser {
    if (self = [super init]) {
        self.webService = [[CMWebService alloc] init];
        self.user = theUser;
        lastError = nil;
        _cachedAppObjects = [[NSMutableDictionary alloc] init];
        _cachedUserObjects = theUser ? [[NSMutableDictionary alloc] init] : nil;
    }
    return self;
}

- (void)setUser:(CMUser *)theUser {
    @synchronized(self) {
        if (_cachedUserObjects) {
            [_cachedUserObjects enumerateKeysAndObjectsUsingBlock:^(id key, CMObject *obj, BOOL *stop) {
                obj.store = nil;
            }];
            [_cachedUserObjects removeAllObjects];
        } else {
            _cachedUserObjects = [[NSMutableDictionary alloc] init];
        }
        user = theUser;
    }
}

#pragma mark - Store state

- (CMObjectOwnershipLevel)objectOwnershipLevel:(CMObject *)theObject {
    if ([_cachedAppObjects objectForKey:theObject.objectId] != nil) {
        return CMObjectOwnershipAppLevel;
    } else if ([_cachedUserObjects objectForKey:theObject.objectId] != nil) {
        return CMObjectOwnershipUserLevel;
    } else {
        return CMObjectOwnershipUndefinedLevel;
    }
}

#pragma mark - Object retrieval

- (void)allObjects:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options {    
    [self _allObjects:callback userLevel:NO additionalOptions:options];
}

- (void)allUserObjects:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options {
    _CMAssertUserConfigured;
    
    [self _allObjects:callback userLevel:YES additionalOptions:options];
}

- (void)_allObjects:(CMStoreObjectFetchCallback)callback userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options {
    [self _objectsWithKeys:nil callback:callback userLevel:userLevel additionalOptions:options];
}

- (void)objectsWithKeys:(NSArray *)keys callback:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options {
    [self _objectsWithKeys:keys callback:callback userLevel:NO additionalOptions:options];
}

- (void)userObjectsWithKeys:(NSArray *)keys callback:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options {
    _CMAssertUserConfigured;
    
    [self _objectsWithKeys:keys callback:callback userLevel:YES additionalOptions:options];
}
- (void)_objectsWithKeys:(NSArray *)keys callback:(CMStoreObjectFetchCallback)callback userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options {
    NSParameterAssert(callback);
    _CMAssertAPICredentialsInitialized;
    
    __unsafe_unretained CMStore *blockSelf = self;
    [webService getValuesForKeys:keys
              serverSideFunction:options.serverSideFunction
                   pagingOptions:options.pagingDescriptor 
                            user:_CMUserOrNil
                  successHandler:^(NSDictionary *results, NSDictionary *errors) {
                      NSArray *objects = [CMObjectDecoder decodeObjects:results];
                      [blockSelf cacheObjectsInMemory:objects atUserLevel:userLevel];
                      callback(objects, errors);
                  } errorHandler:^(NSError *error) {
                      NSLog(@"Error occurred during object request: %@", [error description]);
                      lastError = error;
                      callback(nil, nil);
                  }
     ];
}

#pragma mark Object querying by type

- (void)allObjects:(CMStoreObjectFetchCallback)callback ofType:(Class)klass additionalOptions:(CMStoreOptions *)options {
    [self _allObjects:callback ofType:klass userLevel:NO additionalOptions:options];
}

- (void)allUserObjects:(CMStoreObjectFetchCallback)callback ofType:(Class)klass additionalOptions:(CMStoreOptions *)options {
    _CMAssertUserConfigured;
    
    [self _allObjects:callback ofType:klass userLevel:YES additionalOptions:options];
}

- (void)_allObjects:(CMStoreObjectFetchCallback)callback ofType:(Class)klass userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options {
    NSParameterAssert(callback);
    NSParameterAssert(klass);
    NSAssert(class_respondsToSelector(klass, @selector(className)), @"You must pass a class (%@) that extends CMObject and responds to +className.", klass);
    _CMAssertAPICredentialsInitialized;
    
    [self _searchObjects:callback 
                   query:[NSString stringWithFormat:@"[%@ = \"%@\"]", CMInternalTypeStorageKey, [klass className]]
               userLevel:userLevel
       additionalOptions:options];
}

#pragma mark General object querying

- (void)searchObjects:(CMStoreObjectFetchCallback)callback query:(NSString *)query additionalOptions:(CMStoreOptions *)options {
    [self _searchObjects:callback query:query userLevel:NO additionalOptions:options];
}

- (void)searchUserObjects:(CMStoreObjectFetchCallback)callback query:(NSString *)query additionalOptions:(CMStoreOptions *)options {
    _CMAssertUserConfigured;
    
    [self _searchObjects:callback query:query userLevel:YES additionalOptions:options];
}

- (void)_searchObjects:(CMStoreObjectFetchCallback)callback query:(NSString *)query userLevel:(BOOL)userLevel additionalOptions:(CMStoreOptions *)options {
    NSParameterAssert(callback);
    _CMAssertAPICredentialsInitialized;
    
    if (!query || [query length] == 0) {
        NSLog(@"No query provided, so executing standard all-object retrieval");
        return [self _allObjects:callback userLevel:userLevel additionalOptions:options];
    }
    
    __unsafe_unretained CMStore *blockSelf = self;
    [webService searchValuesFor:query
             serverSideFunction:options.serverSideFunction
                  pagingOptions:options.pagingDescriptor 
                           user:_CMUserOrNil
                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                     NSArray *objects = [CMObjectDecoder decodeObjects:results];
                     [blockSelf cacheObjectsInMemory:objects atUserLevel:userLevel];
                     callback(objects, errors);
                 } errorHandler:^(NSError *error) {
                     NSLog(@"Error occurred during object request: %@", [error description]);
                     lastError = error;
                     callback(nil, nil);
                 }
     ];
}

#pragma mark Object uploading

- (void)saveAll:(CMStoreUploadCallback)callback {
    __unsafe_unretained CMStore *selff = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        [selff saveAllAppObjects:callback];
    });
    
    if (user) {
        dispatch_async(queue, ^{
            [selff saveAllUserObjects:callback];
        });
    }
}

- (void)saveAllAppObjects:(CMStoreUploadCallback)callback {
    [self _saveObjects:[_cachedAppObjects allValues] userLevel:NO callback:callback];
}

- (void)saveAllUserObjects:(CMStoreUploadCallback)callback {
    [self _saveObjects:[_cachedUserObjects allValues] userLevel:YES callback:callback];
}

- (void)saveUserObject:(CMObject *)theObject callback:(CMStoreUploadCallback)callback {
    _CMAssertUserConfigured;
    [self _saveObjects:[NSSet setWithObject:theObject] userLevel:YES callback:callback];
}

- (void)saveObject:(CMObject *)theObject callback:(CMStoreUploadCallback)callback {
    [self _saveObjects:[NSSet setWithObject:theObject] userLevel:NO callback:callback];
}

- (void)_saveObjects:(NSArray *)objects userLevel:(BOOL)userLevel callback:(CMStoreUploadCallback)callback {
    NSParameterAssert(objects);
    _CMAssertAPICredentialsInitialized;
    [webService updateValuesFromDictionary:[CMObjectEncoder encodeObjects:objects]
                        serverSideFunction:nil
                                      user:_CMUserOrNil
                            successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                callback(results);
                            } errorHandler:^(NSError *error) {
                                NSLog(@"Error occurred during object uploading: %@", [error description]);
                                lastError = error;
                                callback(nil);
                            }
     ];
}

#pragma mark Object and file deletion

- (void)deleteObject:(id<CMSerializable>)theObject callback:(CMStoreDeleteCallback)callback {
    NSParameterAssert(theObject);
    [self _deleteObjects:[NSArray arrayWithObject:theObject] userLevel:NO callback:callback];
}

- (void)deleteUserObject:(id<CMSerializable>)theObject callback:(CMStoreDeleteCallback)callback {
    NSParameterAssert(theObject);
    _CMAssertUserConfigured;
    [self _deleteObjects:[NSArray arrayWithObject:theObject] userLevel:YES callback:callback];    
}

- (void)deleteObjects:(NSArray *)objects callback:(CMStoreDeleteCallback)callback {
    [self _deleteObjects:objects userLevel:NO callback:callback];
}

- (void)deleteUserObjects:(NSArray *)objects callback:(CMStoreDeleteCallback)callback {
    _CMAssertUserConfigured;
    [self _deleteObjects:objects userLevel:YES callback:callback];
}

- (void)_deleteObjects:(NSArray *)objects userLevel:(BOOL)userLevel callback:(CMStoreDeleteCallback)callback {
    NSParameterAssert(objects);
    _CMAssertAPICredentialsInitialized;
    
    // Remove the objects from the cache first.
    NSMutableDictionary *cache = userLevel ? _cachedUserObjects : _cachedAppObjects;
    NSMutableDictionary *deletedObjects = [NSMutableDictionary dictionaryWithCapacity:objects.count];
    [objects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
        [deletedObjects setObject:obj forKey:obj.objectId];
        [cache removeObjectForKey:obj.objectId];
    }];
    
    NSArray *keys = [deletedObjects allKeys];
    [webService deleteValuesForKeys:keys
                               user:_CMUserOrNil
                     successHandler:^(NSDictionary *results, NSDictionary *errors) {
                         callback(YES);
                     } errorHandler:^(NSError *error) {
                         NSLog(@"An error occurred when deleting objects with keys (%@): %@", keys, error);
                         lastError = error;
                         callback(NO);
                     }
     ];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CMStoreObjectDeletedNotification
                                                        object:self
                                                      userInfo:deletedObjects];
}

#pragma mark Binary file loading

- (void)fileWithName:(NSString *)name callback:(CMStoreFileFetchCallback)callback {
    [self _fileWithName:name userLevel:NO callback:callback];
}

- (void)userFileWithName:(NSString *)name callback:(CMStoreFileFetchCallback)callback {
    _CMAssertUserConfigured;
    
    [self _fileWithName:name userLevel:YES callback:callback];
}

- (void)_fileWithName:(NSString *)name userLevel:(BOOL)userLevel callback:(CMStoreFileFetchCallback)callback {
    NSParameterAssert(name);
    NSParameterAssert(callback);
    
    [webService getBinaryDataNamed:name
                              user:_CMUserOrNil
                    successHandler:^(NSData *data, NSString *mimeType) {
                        CMFile *file = [[CMFile alloc] initWithData:data
                                                              named:name
                                                    belongingToUser:userLevel ? user : nil
                                                           mimeType:mimeType];
                        [file writeToCache];
                        callback(file);
                    } errorHandler:^(NSError *error) {
                        NSLog(@"Error occurred during file request: %@", [error description]);
                        lastError = error;
                        callback(nil);
                    }
     ];
}

#pragma mark - In-memory caching

- (void)cacheObjectsInMemory:(NSArray *)objects atUserLevel:(BOOL)userLevel {
    NSAssert(userLevel ? (user != nil) : true, @"Failed trying to cache remote objects in-memory for user when user is not configured (%@)", self);
    
    @synchronized(self) {
        NSMutableDictionary *cache = userLevel ? _cachedUserObjects : _cachedAppObjects;
        for (CMObject *obj in objects) {
            [cache setObject:obj forKey:obj.objectId];
        }
    }
}

- (void)addUserObject:(CMObject *)theObject {
    NSAssert(user != nil, @"Attempted to add object (%@) to store (%@) belonging to user when user is not set.", theObject, self);
    @synchronized(self) {
        [_cachedUserObjects setObject:theObject forKey:theObject.objectId];
    }
    theObject.store = self;
}

- (void)addObject:(CMObject *)theObject {
    @synchronized(self) {
        [_cachedAppObjects setObject:theObject forKey:theObject.objectId];
    }
    theObject.store = self;
}

- (void)removeObject:(CMObject *)theObject {
    @synchronized(self) {
        [_cachedAppObjects removeObjectForKey:theObject.objectId];
    }
    theObject.store = nil;
}

- (void)removeUserObject:(CMObject *)theObject {
    @synchronized(self) {
        [_cachedUserObjects removeObjectForKey:theObject.objectId];
    }
    theObject.store = nil;
}

@end
