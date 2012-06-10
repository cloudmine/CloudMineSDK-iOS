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

SPEC_BEGIN(CMObjectSpec)

describe(@"CMObject", ^{
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppSecret:@"appSecret"];
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"appIdentifier"];
    });

    context(@"given an object that belongs to an app-level store", ^{
        it(@"should add itself to the new store and remove itself from the old one when a new store is assigned", ^{
            CMObject *obj = [[CMObject alloc] init];
            CMStore *newStore = [CMStore store];
            [[obj.store should] equal:[CMStore defaultStore]];

            obj.store = newStore;

            [[theValue([[CMStore defaultStore] objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [[theValue([newStore objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[obj.store should] equal:newStore];
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
