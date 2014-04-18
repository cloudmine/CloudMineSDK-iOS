//
//  CMACLSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMACL.h"
#import "CMACLFetchResponse.h"

extern void __gcov_flush();

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

SPEC_BEGIN(CMACLFetchResponseSpec)

describe(@"CMACLFetchResponse", ^{
    __block CMACLFetchResponse *response;

    beforeAll(^{
        CMACL *firstACL = [[CMACL alloc] init];
        firstACL.members = [NSSet setWithObjects:@"Conrad", @"Marc", nil];
        firstACL.permissions = [NSSet setWithObjects:CMACLReadPermission, CMACLDeletePermission, nil];
        
        CMACL *secondACL = [[CMACL alloc] init];
        secondACL.members = [NSSet setWithObjects:@"Derek", @"Ilya", nil];
        secondACL.permissions = [NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, nil];
        
        CMACL *thirdACL = [[CMACL alloc] init];
        thirdACL.members = [NSSet setWithObjects:@"Brendan", @"John", @"Conrad", nil];
        thirdACL.permissions = [NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, nil];
        
        response = [[CMACLFetchResponse alloc] init];
        response.acls = [NSSet setWithObjects:firstACL, secondACL, thirdACL, nil];
    });

    context(@"given a reasonably complex ACL response", ^{
        
        it(@"should return a set of all users correctly", ^{
            [[[response allMembers] should] equal:[NSSet setWithObjects:@"Conrad", @"Marc", @"John", @"Derek", @"Ilya", @"Brendan", nil]];
        });

        it(@"should return a set of all common permissions correctly", ^{
            [[[response permissionsForAllMembers] should] equal:[NSSet setWithObject:CMACLReadPermission]];
        });
        
        it(@"should return a set of maximum permissions for a user correctly", ^{
            [[[response permissionsForMember:@"Conrad"] should] equal:[NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, CMACLDeletePermission, nil]];
        });
        
        it(@"should return a set of members with a specific permission correctly", ^{
            [[[response membersWithPermissions:[NSSet setWithObject:CMACLUpdatePermission]] should] equal:[NSSet setWithObjects:@"Derek", @"Ilya", @"Brendan", @"John", @"Conrad", nil]];
        });
    });
    
    afterAll(^{
        __gcov_flush();
    });
});

SPEC_END
