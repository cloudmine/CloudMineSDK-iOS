//
//  CMACLSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMACL.h"
#import "CMWebService.h"
#import "CMAPICredentials.h"
#import "CMWebService.h"
#import "CMObjectDecoder.h"
#import "CMObjectEncoder.h"

SPEC_BEGIN(CMACLSpec)

describe(@"CMACL", ^{
    __block CMACL *acl;
    __block CMStore *store;

    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"appSecret" andApiKey:@"appIdentifier"];
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
        
        it(@"should raise an exception if attempting to add an ACL to a store with no user", ^{
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            store.user = nil;
            [[theBlock(^{ [store addACL:acl]; }) should] raiseWithName:NSInternalInconsistencyException];
        });
        
        it(@"it should become cached when added to the store", ^{
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [store addACL:acl];
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUserLevel)];
        });
        
        it(@"should have a no ownership with a null store", ^{
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            acl.store = nil;
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
        });
        
        it(@"it should save with the web service if cached", ^{
            [store addACL:acl];
            [[theValue([acl ownershipLevel]) should] equal:theValue(CMObjectOwnershipUserLevel)];
            
            [[store.webService should] receive:@selector(updateACL:user:successHandler:errorHandler:) withCount:1];
            [store saveAllACLs:nil];
        });
        
        it(@"should raise an exception if attempting to view or modify ACLs", ^{
            [[theBlock(^{ [acl getACLs:nil]; }) should] raiseWithName:NSInternalInconsistencyException];
            [[theBlock(^{ [acl saveACLs:nil]; }) should] raiseWithName:NSInternalInconsistencyException];
            [[theBlock(^{ [acl addACLs:nil callback:nil]; }) should] raiseWithName:NSInternalInconsistencyException];
            [[theBlock(^{ [acl addACL:nil callback:nil]; }) should] raiseWithName:NSInternalInconsistencyException];
            [[theBlock(^{ [acl removeACLs:nil callback:nil]; }) should] raiseWithName:NSInternalInconsistencyException];
            [[theBlock(^{ [acl removeACL:nil callback:nil]; }) should] raiseWithName:NSInternalInconsistencyException];
        });
    });
    
    context(@"given an ACL that can be serialized and deserialized", ^{
        it(@"should serialize properly", ^{
            CMACL *newACL = [[CMACL alloc] initWithObjectId:@"id"];
            newACL.members = [NSSet setWithObject:@"testing"];
            newACL.permissions = [NSSet setWithObject:CMACLReadPermission];
            
            NSDictionary *dictionary = [CMObjectEncoder encodeObjects:@[newACL]];
            [[dictionary should] haveCountOf:1];
            NSDictionary *inside = dictionary[@"id"];
            [[inside shouldNot] beNil];
            [[inside should] haveCountOf:7];
            [[inside[@"__id__"] should] equal:@"id"];
            [[inside[@"__class__"] should] equal:@"acl"];
            [[inside[@"members"] should] haveCountOf:1];
            [[inside[@"members"][0] should] equal:@"testing"];
            [[inside[@"permissions"] should] haveCountOf:1];
            [[inside[@"permissions"][0] should] equal:@"r"];
            [[[inside[@"segments"] allKeys] should] beEmpty];
        });
        
        it(@"should deserialize properly", ^{
            CMACL *newACL = [[CMACL alloc] initWithObjectId:@"id"];
            newACL.members = [NSSet setWithObject:@"testing"];
            newACL.permissions = [NSSet setWithObject:CMACLReadPermission];
            
            NSDictionary *dictionary = [CMObjectEncoder encodeObjects:@[newACL]];
            
            CMACL *remade = [[CMObjectDecoder decodeObjects:dictionary] lastObject];
            [[remade.objectId should] equal:@"id"];
            [[remade.permissions should] haveCountOf:1];
            [[remade.members should] haveCountOf:1];
            [[[remade.permissions allObjects][0] should] equal:CMACLReadPermission];
            [[[remade.members allObjects][0] should] equal:@"testing"];
        });
    });
    
    context(@"given an ACL that could be saved", ^{
        
        it(@"should be able to be saved if the store has a user", ^{
            [acl save:nil];
            [store.webService captureArgument:@selector(updateACL:user:successHandler:errorHandler:) atIndex:1];
            [[acl.store should] equal:[CMStore defaultStore]];
        });
        
        it(@"should be able to switch stores", ^{
            CMStore *newStore = [CMStore store];
            newStore.user = [[CMUser alloc] init];
            newStore.user.token = @"1234";
            newStore.user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0];
            
            [newStore addACL:acl];
            [[acl.store should] equal:newStore];
            
            CMStore *another = [CMStore store];
            another.user = [[CMUser alloc] init];
            another.user.token = @"1234";
            another.user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0];
            
            [another addACL:acl];
            [[acl.store should] equal:another];
        });
        
    });
});

SPEC_END
