//
//  CMUserCredentials.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMUser.h"
#import "CMWebService.h"
#import "CMObjectSerialization.h"
#import "CMObjectDecoder.h"
#import "CMObjectEncoder.h"

#import "MARTNSObject.h"
#import "RTProperty.h"

@interface CMUser ()
+ (NSURL *)cacheLocation;
+ (NSMutableDictionary *)cachedUsers;
+ (CMUser *)userFromCacheWithIdentifier:(NSString *)objectId;
+ (void)cacheMultipleUsers:(NSArray *)users;
- (void)writeToCache;
@end

static CMWebService *webService;

@implementation CMUser

@synthesize userId;
@synthesize password;
@synthesize token;
@synthesize tokenExpiration;
@synthesize objectId;
@synthesize isDirty;

+ (NSString *)className {
    return NSStringFromClass([self class]);
}

#pragma mark - Constructors

+ (void)initialize {
    if (!webService) {
        @try {
            webService = [[CMWebService alloc] init];
        } @catch (NSException *e) {
            webService = nil;
        }
    }
}

- (id)init
{
    if (self = [super init]) {
        self.token = nil;
        self.userId = nil;
        self.password = nil;
        objectId = @"";
        if (!webService) {
            webService = [[CMWebService alloc] init];
        }
        isDirty = NO;
        [self registerAllPropertiesForKVO];
    }
    return self;
}

- (id)initWithUserId:(NSString *)theUserId andPassword:(NSString *)thePassword {
    if (self = [super init]) {
        self.token = nil;
        self.userId = theUserId;
        self.password = thePassword;
        objectId = @"";
        if (!webService) {
            webService = [[CMWebService alloc] init];
        }
        isDirty = NO;
        [self registerAllPropertiesForKVO];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        objectId = [coder decodeObjectForKey:CMInternalObjectIdKey];
        if (!objectId) {
            objectId = @"";
        }
        token = [coder decodeObjectForKey:@"token"];
        tokenExpiration = [coder decodeObjectForKey:@"tokenExpiration"];
        if (!webService) {
            webService = [[CMWebService alloc] init];
        }
        isDirty = NO;
        [self registerAllPropertiesForKVO];
    }
    return self;
}

- (void)dealloc {
    [self deregisterAllPropertiesForKVO];
}

#pragma mark - Dirty tracking

- (void)executeBlockForAllUserDefinedProperties:(void (^)(RTProperty *property))block {
    NSArray *properties = [[self class] rt_properties];
    NSArray *ignoredProperties = [NSSet setWithArray:[CMUser rt_properties]]; // none of these are user profile fields, so ignore them
    for (RTProperty *property in properties) {
        if (![ignoredProperties containsObject:property]) {
            block(property);
        }
    }
}

- (void)registerAllPropertiesForKVO {
    [self executeBlockForAllUserDefinedProperties:^(RTProperty *property) {
        [self addObserver:self forKeyPath:[property name] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }];
}

- (void)deregisterAllPropertiesForKVO {
    [self executeBlockForAllUserDefinedProperties:^(RTProperty *property) {
        [self removeObserver:self forKeyPath:[property name]];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.isCreatedRemotely) {
        // Only change the state to dirty if the object has been at least saved remotely once. Doesn't matter otherwise and
        // just confuses matters.
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (![oldValue isEqual:newValue]) {
            // Only apply the change if a change was actually made.
            NSLog(@"Detected change for property %@. Old value was \"%@\", new value is \"%@\"", keyPath, oldValue, newValue);
            isDirty = YES;
        }
    }
}

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.objectId forKey:CMInternalObjectIdKey];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeObject:self.tokenExpiration forKey:@"tokenExpiration"];
}

#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CMUser class]]) {
        return NO;
    }

    if (userId) {
        return ([[object userId] isEqualToString:userId] && [[object password] isEqualToString:password]);
    } else {
        return ([[object token] isEqualToString:token]);
    }
}

#pragma mark - State operations and accessors

- (BOOL)isLoggedIn {
    return (self.token != nil && [self.tokenExpiration compare:[NSDate date]] == NSOrderedDescending /* if token comes after now */);
}

- (void)setToken:(NSString *)theToken {
    @synchronized(self) {
        token = theToken;

        // Once a token is set, clear the password for security reasons.
        self.password = nil;
    }
}

- (NSString *)token {
    @synchronized(self) {
        return token;
    }
}

- (void)copyValuesFromDictionaryIntoState:(NSDictionary *)dict {
    for (NSString *key in dict) {
        if (![CMInternalKeys containsObject:key]) {
            [self setValue:[dict objectForKey:key] forKey:key];
        }
    }
    isDirty = NO;
}

#pragma mark - Remote user account and session operations

- (BOOL)isCreatedRemotely {
    // objectId is set server side, so if it's empty it hasn't been sent over the wire yet.
    return (![self.objectId isEqualToString:@""]);
}

- (void)save:(CMUserOperationCallback)callback {
    [webService saveUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        [self copyValuesFromDictionaryIntoState:responseBody];
        if (callback) {
            callback(result, [NSDictionary dictionary]);
        }
    }];
}

- (void)loginWithCallback:(CMUserOperationCallback)callback {
    [webService loginUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];

        if (result == CMUserAccountLoginSucceeded) {
            self.token = [responseBody objectForKey:@"session_token"];

            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setLenient:YES];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"; // RFC 1123 format
            self.tokenExpiration = [df dateFromString:[responseBody objectForKey:@"expires"]];

            NSDictionary *userProfile = [responseBody objectForKey:@"profile"];
            objectId = [userProfile objectForKey:CMInternalObjectIdKey];

            if (!self.isDirty) {
                // Only bring the changes from the server into the object state if there weren't local modifications.
                [self copyValuesFromDictionaryIntoState:userProfile];
            }
        }

        if (callback) {
            callback(result, messages);
        }
    }];
}

- (void)logoutWithCallback:(CMUserOperationCallback)callback {
    [webService logoutUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];
        if (result == CMUserAccountLogoutSucceeded) {
            self.token = nil;
            self.tokenExpiration = nil;
        } else {
            messages = [responseBody allValues];
        }

        if (callback) {
            callback(result, messages);
        }
    }];
}

- (void)createAccountWithCallback:(CMUserOperationCallback)callback {
    [webService createAccountWithUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];

        if (result != CMUserAccountCreateSucceeded) {
            messages = [responseBody objectForKey:@"errors"];
        } else {
            objectId = [responseBody objectForKey:CMInternalObjectIdKey];
            isDirty = NO;
        }

        if (callback) {
            callback(result, messages);
        }
    }];
}

- (void)createAccountAndLoginWithCallback:(CMUserOperationCallback)callback {
    [self createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
        if (resultCode == CMUserAccountCreateFailedDuplicateAccount || resultCode == CMUserAccountCreateSucceeded) {
            [self loginWithCallback:callback];
        } else {
            if (callback) {
                callback(resultCode, messages);
            }
        }
    }];
}

- (void)changePasswordTo:(NSString *)newPassword from:(NSString *)oldPassword callback:(CMUserOperationCallback)callback {
    [webService changePasswordForUser:self
                           oldPassword:oldPassword
                           newPassword:newPassword
                              callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
                                  if (result == CMUserAccountPasswordChangeSucceeded) {
                                      self.password = newPassword;

                                      // Since the password change succeeded, the user needs to be logged back
                                      // in again to get a new session token since the old one has been expired.
                                      [self loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                                          callback(CMUserAccountPasswordChangeSucceeded, [NSArray array]);
                                      }];
                                  } else  {
                                      callback(result, [NSArray array]);
                                  }
                              }
     ];
}

- (void)resetForgottenPasswordWithCallback:(CMUserOperationCallback)callback {
    [webService resetForgottenPasswordForUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        if (callback) {
            callback(result, [NSArray array]);
        }
    }];
}

#pragma mark - Discovering other users

+ (void)allUsersWithCallback:(CMUserFetchCallback)callback {
    NSParameterAssert(callback);
    [webService getAllUsersWithCallback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
        NSArray *users = [CMObjectDecoder decodeObjects:results];
        [self cacheMultipleUsers:users];
        callback(users, errors);
    }];
}

+ (void)searchUsers:(NSString *)query callback:(CMUserFetchCallback)callback {
    NSParameterAssert(callback);
    [webService searchUsers:query callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
        NSArray *users = [CMObjectDecoder decodeObjects:results];
        [self cacheMultipleUsers:users];
        callback(users, errors);
    }];
}

+ (void)userWithIdentifier:(NSString *)identifier callback:(CMUserFetchCallback)callback {
    NSParameterAssert(callback);

    CMUser *cachedUser = [self userFromCacheWithIdentifier:identifier];
    if (cachedUser) {
        callback($array(cachedUser), [NSDictionary dictionary]);
    } else {
        [webService getUserProfileWithIdentifier:identifier callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            if (errors.count > 0) {
                callback([NSArray array], errors);
            } else {
                NSArray *users = [CMObjectDecoder decodeObjects:results];
                [self cacheMultipleUsers:users];
                callback(users, errors);
            }
        }];
    }
}

#pragma mark - Caching

+ (NSURL *)cacheLocation {
    static NSURL *_cacheLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheLocation = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        _cacheLocation = [_cacheLocation URLByAppendingPathComponent:@"cmusers.plist"];
    });

    return _cacheLocation;
}

+ (NSMutableDictionary *)cachedUsers {
    NSURL *cacheLocation = [self cacheLocation];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheLocation relativePath]]) {
        // Since the file doesn't already exist, create it with an empty dictionary.
        [[NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionary]] writeToURL:cacheLocation atomically:YES];
        return [NSMutableDictionary dictionary];
    }
    return [[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:cacheLocation]] mutableCopy];
}

- (void)writeToCache {
    [CMUser cacheMultipleUsers:$array(self)];
}

+ (void)cacheMultipleUsers:(NSArray *)users {
    NSMutableDictionary *cachedUsers = [self cachedUsers];
    [users enumerateObjectsUsingBlock:^(CMUser *obj, NSUInteger idx, BOOL *stop) {
        [cachedUsers setObject:obj forKey:obj.objectId];
    }];

    [[NSKeyedArchiver archivedDataWithRootObject:cachedUsers] writeToURL:[self cacheLocation] atomically:YES];
}

+ (CMUser *)userFromCacheWithIdentifier:(NSString *)objectId {
    return [[self cachedUsers] objectForKey:objectId];
}

#pragma mark - Private stuff

- (void)setWebService:(CMWebService *)newWebService {
    webService = newWebService;
}

- (CMWebService *)webService {
    return webService;
}

@end
