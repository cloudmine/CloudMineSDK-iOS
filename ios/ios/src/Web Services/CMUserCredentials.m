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

- (id)initWithUserId:(NSString *)theUserId andPassword:(NSString *)thePassword {
    if (self = [super init]) {
        self.userId = theUserId;
        self.password = thePassword;
    }
    return self;
}

@end
