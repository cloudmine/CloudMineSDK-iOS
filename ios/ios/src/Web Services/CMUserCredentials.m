//
//  CMUserCredentials.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMUserCredentials.h"

@implementation CMUserCredentials
@synthesize userId, password;

- (id)initWithUserId:(NSString *)userId andPassword:(NSString *)password {
    if (self = [super init]) {
        self.userId = userId;
        self.password = password;
    }
    return self;
}

@end
