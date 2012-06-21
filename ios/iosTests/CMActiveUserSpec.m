//
//  CMActiveUserSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

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
});

SPEC_END
