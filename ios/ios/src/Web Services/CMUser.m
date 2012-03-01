//
//  CMUserCredentials.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMUser.h"
#import "CMWebService.h"

@implementation CMUser
@synthesize userId;
@synthesize password;
@synthesize token;

#pragma mark - Constructors

- (id)initWithUserId:(NSString *)theUserId andPassword:(NSString *)thePassword {
    if (self = [super init]) {
        self.userId = theUserId;
        self.password = thePassword;
        self.token = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.token = [coder decodeObjectForKey:@"token"];
    }
    return self;
}

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.token forKey:@"token"];
}

#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CMUser class]]) {
        return NO;
    }
    return ([[object userId] isEqualToString:userId] && [[object password] isEqualToString:password]);
}

#pragma mark - State operations and accessors

- (BOOL)isLoggedIn {
    return (self.token != nil);
}

- (void)setToken:(NSString *)theToken {
    @synchronized(self) {
        if (theToken != nil) {
            token = theToken;
            
            // Once a token is set, clear the password for security reasons.
            self.password = nil;
        }
    }
}

- (NSString *)token {
    @synchronized(self) {
        return token;
    }
}

#pragma mark - Remote user account and session operations

- (void)loginWithCallback:(CMUserOperationCallback)callback {
    
}

- (void)logoutWithCallback:(CMUserOperationCallback)callback {
    
}

- (void)changePasswordTo:(NSString *)newPassword callback:(CMUserOperationCallback)callback {
    
}

- (void)resetPasswordWithCallback:(CMUserOperationCallback)callback {
    
}

@end
