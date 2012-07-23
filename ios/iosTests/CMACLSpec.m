//
//  CMACLSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMACL.h"
#import "CMAPICredentials.h"

SPEC_BEGIN(CMACLSpec)

describe(@"CMACL", ^{
    __block CMACL *acl;
    __block CMStore *store;

    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppSecret:@"appSecret"];
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"appIdentifier"];
    });

    beforeEach(^{
        acl = [[CMACL alloc] init];
        store = [CMStore defaultStore];
        store.webService = [CMWebService nullMock];
        store.user = [[CMUser alloc] init];
        store.user.token = @"1234";
        store.user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0];
    });

    context(@"given an ACL that does not belong to a store", ^{
        it(@"it should become cached when added to the store", ^{
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [store addACL:acl];
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUserLevel)];
            
        });
        
        it(@"it should save with the web service if cached", ^{
            [store addACL:acl];
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUserLevel)];
            
            [[store.webService should] receive:@selector(updateACL:user:successHandler:errorHandler:) withCount:1];
            [store saveAllACLs:nil];
        });
        
        it(@"should raise an exception if attempting to view or modify ACLs", ^{
            [[theBlock(^{ [acl getACLs:nil]; }) should] raise];
            [[theBlock(^{ [acl saveACLs:nil]; }) should] raise];
            [[theBlock(^{ [acl addACLs:nil callback:nil]; }) should] raise];
            [[theBlock(^{ [acl removeACLs:nil callback:nil]; }) should] raise];
        });
    });
});

SPEC_END
