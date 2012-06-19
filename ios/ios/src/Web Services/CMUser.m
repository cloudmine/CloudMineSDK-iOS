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

@interface CMUser ()
@property CMWebService *webService;
@end

@implementation CMUser

@synthesize userId;
@synthesize password;
@synthesize token;
@synthesize tokenExpiration;
@synthesize webService;
@synthesize objectId;

+ (NSString *)className {
    return @"user";
}

#pragma mark - Constructors

- (id)initWithUserId:(NSString *)theUserId andPassword:(NSString *)thePassword {
    if (self = [super init]) {
        self.token = nil;
        self.userId = theUserId;
        self.password = thePassword;
        webService = [[CMWebService alloc] init];
        objectId = @"";
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
    }
    return self;
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

#pragma mark - Remote user account and session operations

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
            for (NSString *key in userProfile) {
                if (![CMInternalKeys containsObject:key]) {
                    [blockSelf setValue:[userProfile objectForKey:key] forKey:key];
                }
            }
        }

        callback(result, messages);
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

        callback(result, messages);
    }];
}

- (void)createAccountWithCallback:(CMUserOperationCallback)callback {
    [webService createAccountWithUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];

        if (result != CMUserAccountCreateSucceeded) {
            messages = [responseBody objectForKey:@"errors"];
        } else {
            objectId = [responseBody objectForKey:CMInternalObjectIdKey];
        }

        callback(result, messages);
    }];
}

- (void)createAccountAndLoginWithCallback:(CMUserOperationCallback)callback {
    __unsafe_unretained CMUser *blockSelf = self;

    [self createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
        if (resultCode == CMUserAccountCreateFailedDuplicateAccount || resultCode == CMUserAccountCreateSucceeded) {
            [blockSelf loginWithCallback:callback];
        } else {
            callback(resultCode, messages);
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
        callback(result, [NSArray array]);
    }];
}

@end
