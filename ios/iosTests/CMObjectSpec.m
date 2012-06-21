//
//  CMObjectSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMStore.h"
#import "CMNullStore.h"
#import "CMObject.h"
#import "CMAPICredentials.h"
#import "CMUser.h"

SPEC_BEGIN(CMObjectSpec)

describe(@"CMObject", ^{
    __block CMObject *obj;
    __block CMStore *store;

    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppSecret:@"appSecret"];
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"appIdentifier"];
    });

    beforeEach(^{
        obj = [[CMObject alloc] init];
        store = [CMStore defaultStore];
        store.webService = [CMWebService nullMock];
    });

    context(@"given an object that belongs to an app-level store", ^{
        it(@"should add itself to the new store and remove itself from the old one when a new store is assigned", ^{
            CMStore *newStore = [CMStore store];
            [[obj.store should] equal:store];

            obj.store = newStore;

            [[theValue([[CMStore defaultStore] objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [[theValue([newStore objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[obj.store should] equal:newStore];
        });

        it(@"should save at the app level when save is called directly on the object", ^{
            [obj save:nil];
            [[theValue([obj ownershipLevel]) should] equal:theValue(CMObjectOwnershipAppLevel)];
        });

        it(@"should throw an exception if the object is subsequently saved with a user", ^{
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@test.com" andPassword:@"pass"];
            [obj save:nil];
            [[theValue([obj ownershipLevel]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[theBlock(^{ [obj saveWithUser:user callback:nil]; }) should] raise];
        });
    });

    context(@"given an object that belongs to a user-level store", ^{
        it(@"should save at the user level when save is called directly on the object", ^{
            CMUser *user = [[CMUser alloc] init];
            user.token = @"1234";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0]; // set it to the future

            store.user = user;
            [store addUserObject:obj];

            [obj save:nil];
            [[theValue(obj.ownershipLevel) should] equal:theValue(CMObjectOwnershipUserLevel)];
        });
    });

    context(@"given an object that doesn't belong to a store yet", ^{
        it(@"should save to the app-level when save: is called on the object", ^{
            [obj save:nil];
            [[theValue(obj.ownershipLevel) should] equal:theValue(CMObjectOwnershipAppLevel)];
        });

        it(@"should save to the user-level when saveWithUser: is called on the object", ^{
            CMUser *user = [[CMUser alloc] init];
            user.token = @"1234";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0]; // set it to the future

            [obj saveWithUser:user callback:nil];
            [[theValue(obj.ownershipLevel) should] equal:theValue(CMObjectOwnershipUserLevel)];
        });
    });

    context(@"given an object that belongs to any store", ^{
        it(@"should set its store to the CMNullStore singleton when the store is set to nil", ^{
            CMObject *obj = [[CMObject alloc] init];
            [[obj.store should] equal:[CMStore defaultStore]];
            obj.store = nil;
            [[obj.store should] equal:[CMNullStore nullStore]];
        });
    });
});

SPEC_END
