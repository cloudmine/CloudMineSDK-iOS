//
//  CMActiveUserSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

extern void __gcov_flush();

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "Kiwi.h"
#import "CMActiveUser.h"

SPEC_BEGIN(CMActiveUserSpec)

describe(@"CMActiveUser", ^{
    afterEach(^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cmau"];
    });

    it(@"should persist itself when the singleton is accessed for the first time", ^{
        CMActiveUser *activeUser = [CMActiveUser currentActiveUser];
        CMActiveUser *readUser = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"cmau"]];
        [[readUser should] equal:activeUser];
        [[[CMActiveUser currentActiveUser] should] equal:activeUser];
    });
    
    it(@"should have same identifier when accessed different times", ^{
        CMActiveUser *user = [CMActiveUser currentActiveUser];
        CMActiveUser *anotherUser = [CMActiveUser currentActiveUser];
        [[user should] equal:anotherUser];
    });
    
    afterAll(^{
        __gcov_flush();
    });
});

SPEC_END
