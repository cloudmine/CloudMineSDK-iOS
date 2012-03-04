//
//  CMUserSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMUser.h"

SPEC_BEGIN(CMUserSpec)

describe(@"CMUser", ^{
   context(@"given a username and password", ^{
       it(@"should record both in memory and return them when the getters are accessed", ^{
           CMUser *user = [[CMUser alloc] initWithUserId:@"someone@domain.com" andPassword:@"pass"];
           [[user.userId should] equal:@"someone@domain.com"];
           [[user.password should] equal:@"pass"];
           [user.token shouldBeNil];
       });
   });

    context(@"given a session token", ^{
        it(@"should no longer maintain a copy of the password", ^{
            CMUser *user = [[CMUser alloc] initWithUserId:@"someone@domain.com" andPassword:@"pass"];
            user.token = @"token";

            [[user.userId should] equal:@"someone@domain.com"];
            [user.password shouldBeNil];
            [[user.token should] equal:@"token"];
        });
    });
});

SPEC_END
