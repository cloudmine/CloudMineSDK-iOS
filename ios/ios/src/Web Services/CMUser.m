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

#import "MARTNSObject.h"
#import "RTProperty.h"

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
    @try {
        webService = [[CMWebService alloc] init];
    } @catch (NSException *e) {
        webService = nil;
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
    __unsafe_unretained CMUser *blockSelf = self;
    [self executeBlockForAllUserDefinedProperties:^(RTProperty *property) {
        [blockSelf addObserver:blockSelf forKeyPath:[property name] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }];
}

- (void)deregisterAllPropertiesForKVO {
    __unsafe_unretained CMUser *blockSelf = self;
    [self executeBlockForAllUserDefinedProperties:^(RTProperty *property) {
        [blockSelf removeObserver:blockSelf forKeyPath:[property name]];
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
    __block CMUser *blockSelf = self;
    [webService saveUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        [blockSelf copyValuesFromDictionaryIntoState:responseBody];
        if (callback) {
            callback(result, [NSDictionary dictionary]);
        }
    }];
}

- (void)loginWithCallback:(CMUserOperationCallback)callback {
    __unsafe_unretained CMUser *blockSelf = self;

    [webService loginUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];

        if (result == CMUserAccountLoginSucceeded) {
            blockSelf.token = [responseBody objectForKey:@"session_token"];

            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setLenient:YES];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"; // RFC 1123 format
            blockSelf.tokenExpiration = [df dateFromString:[responseBody objectForKey:@"expires"]];

            NSDictionary *userProfile = [responseBody objectForKey:@"profile"];
            objectId = [userProfile objectForKey:CMInternalObjectIdKey];

            if (!self.isDirty) {
                // Only bring the changes from the server into the object state if there weren't local modifications.
                [blockSelf copyValuesFromDictionaryIntoState:userProfile];
            }
        }

        if (callback) {
            callback(result, messages);
        }
    }];
}

- (void)logoutWithCallback:(CMUserOperationCallback)callback {
    __unsafe_unretained CMUser *blockSelf = self;

    [webService logoutUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];
        if (result == CMUserAccountLogoutSucceeded) {
            blockSelf.token = nil;
            blockSelf.tokenExpiration = nil;
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
    __unsafe_unretained CMUser *blockSelf = self;

    [self createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
        if (resultCode == CMUserAccountCreateFailedDuplicateAccount || resultCode == CMUserAccountCreateSucceeded) {
            [blockSelf loginWithCallback:callback];
        } else {
            if (callback) {
                callback(resultCode, messages);
            }
        }
    }];
}

- (void)changePasswordTo:(NSString *)newPassword from:(NSString *)oldPassword callback:(CMUserOperationCallback)callback {
    __unsafe_unretained CMUser *blockSelf = self;

    [webService changePasswordForUser:self
                           oldPassword:oldPassword
                           newPassword:newPassword
                              callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
                                  if (result == CMUserAccountPasswordChangeSucceeded) {
                                      blockSelf.password = newPassword;

                                      // Since the password change succeeded, the user needs to be logged back
                                      // in again to get a new session token since the old one has been expired.
                                      [blockSelf loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
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
        callback([CMObjectDecoder decodeObjects:results], errors);
    }];
}

+ (void)searchUsers:(NSString *)query callback:(CMUserFetchCallback)callback {
    NSParameterAssert(callback);
    [webService searchUsers:query callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
        callback([CMObjectDecoder decodeObjects:results], errors);
    }];
}

+ (void)userWithIdentifier:(NSString *)identifier callback:(CMUserFetchCallback)callback {
    NSParameterAssert(callback);
    [webService getUserProfileWithIdentifier:identifier callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
        if (errors.count > 0) {
            callback([NSArray array], errors);
        } else {
            callback([CMObjectDecoder decodeObjects:results], errors);
        }
    }];
}

#pragma mark - Private stuff

- (void)setWebService:(CMWebService *)newWebService {
    webService = newWebService;
}

- (CMWebService *)webService {
    return webService;
}

@end
