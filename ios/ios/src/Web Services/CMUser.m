//
//  CMUserCredentials.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMUser.h"

@implementation CMUser
@synthesize userId;
@synthesize password;
@synthesize token;

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

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.token forKey:@"token"];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CMUser class]]) {
        return NO;
    }
    return ([[object userId] isEqualToString:userId] && [[object password] isEqualToString:password]);
}

@end
