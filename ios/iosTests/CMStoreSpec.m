//
//  CMStoreSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMStore.h"
#import "CMNullStore.h"
#import "CMNullStore.h"
#import "CMWebService.h"
#import "CMGenericSerializableObject.h"
#import "CMAPICredentials.h"
#import "CMBlockValidationMessageSpy.h"

SPEC_BEGIN(CMStoreSpec)

describe(@"CMStore", ^{

    __block CMWebService *webService = nil;
    __block CMStore *store = nil;
    __block CMUser *user = nil;

    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppSecret:@"appSecret"];
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"appIdentifier"];
    });

    beforeEach(^{
        webService = [CMWebService mock];
    });

    context(@"given an app-level store", ^{
        beforeEach(^{
            store = [CMStore store];
            store.webService = webService;
        });

        it(@"should nullify the object's store reference when removed from the store", ^{
            CMObject *obj = [[CMObject alloc] init];
            [store addObject:obj];

            [store removeObject:obj];
            [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [[obj.store should] equal:[CMNullStore nullStore]];
        });

        context(@"when computing object ownership level", ^{
            it(@"should be an unknown level when the object doesn't exist in the store", ^{
                CMObject *obj = [[CMObject alloc] init];
                [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            });

            it(@"should be app-level when the object is added to the store at the app level", ^{
                CMObject *obj = [[CMObject alloc] init];
                [store addObject:obj];
                [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
                [[obj.store should] equal:store];
            });

            it(@"should raise an exception when a user-level object is added", ^{
                CMObject *obj = [[CMObject alloc] init];
                [[theBlock(^{
                    [store addUserObject:obj];
                }) should] raise];
            });
        });
    });

    context(@"given a user-level store", ^{
        beforeEach(^{
            user = [[CMUser alloc] initWithUserId:@"userid" andPassword:@"password"];
            store = [CMStore storeWithUser:user];
            store.webService = webService;
        });

        it(@"should nullify the object's store reference when removed from the store", ^{
            CMObject *obj = [[CMObject alloc] init];
            [store addUserObject:obj];

            [store removeUserObject:obj];
            [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [[obj.store should] equal:[CMNullStore nullStore]];
        });

        context(@"when computing object ownership level", ^{
            it(@"should be an unknown level when the object doesn't exist in the store", ^{
                CMObject *obj = [[CMObject alloc] init];
                [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            });

            it(@"should be app-level when the object is added to the store at the app level", ^{
                CMObject *obj = [[CMObject alloc] init];
                [store addObject:obj];
                [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
                [[obj.store should] equal:store];
            });

            it(@"should be user-level when the object is added to the store at the user level", ^{
                CMObject *obj = [[CMObject alloc] init];
                [store addUserObject:obj];
                [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUserLevel)];
                [[obj.store should] equal:store];
            });
        });

        context(@"when performing a remote operation", ^{
            it(@"should log the user in if they aren't already logged in before saving an object", ^{
                CMObject *obj = [[CMObject alloc] init];
                [[user should] receive:@selector(isLoggedIn)];
                [[user should] receive:@selector(loginWithCallback:)];
                [store saveUserObject:obj callback:nil];
            });

            it(@"should log the user in if they aren't already logged in before deleting an object", ^{
                CMObject *obj = [[CMObject alloc] init];
                [[user should] receive:@selector(isLoggedIn)];
                [[user should] receive:@selector(loginWithCallback:)];
                [store deleteUserObject:obj additionalOptions:nil callback:nil];
            });

            it(@"should log the user in if they aren't already logged in before searching for objects", ^{
                [[user should] receive:@selector(isLoggedIn)];
                [[user should] receive:@selector(loginWithCallback:)];
                [store searchUserObjects:@"" additionalOptions:nil callback:nil];
            });

            it(@"should log the user in if they aren't already logged in before getting objects by key", ^{
                [[user should] receive:@selector(isLoggedIn)];
                [[user should] receive:@selector(loginWithCallback:)];
                [store allUserObjectsWithOptions:nil callback:nil];
            });
        });

        context(@"when changing user ownership of a store", ^{
            it(@"should nullify store relationships with user-level objects stored under the previous user", ^{
                NSMutableArray *userObjects = [NSMutableArray arrayWithCapacity:5];
                NSMutableArray *appObjects = [NSMutableArray arrayWithCapacity:5];
                for (int i=0; i<5; i++) {
                    CMObject *userObject = [[CMObject alloc] init];
                    CMObject *appObject = [[CMObject alloc] init];
                    [userObjects addObject:userObject];
                    [appObjects addObject:appObject];
                    [store addUserObject:userObject];
                    [store addObject:appObject];
                }

                // Validate that all the objects have been configured properly.
                [userObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:store];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUserLevel)];
                }];
                [appObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:store];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
                }];

                // Now change the store user and re-validate.
                CMUser *theOtherUser = [[CMUser alloc] initWithUserId:@"somethingelse" andPassword:@"foobar"];
                store.user = theOtherUser;
                [userObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:[CMNullStore nullStore]];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
                }];
                [appObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:store];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
                }];
            });
        });

        context(@"when removing any object from a store", ^{
            it(@"should cause the object's store to be CMNullStore", ^{
                CMObject *obj = [[CMObject alloc] init];
                [[obj.store should] equal:[CMStore defaultStore]];
                [[CMStore defaultStore] removeObject:obj];
                [[obj.store should] equal:[CMNullStore nullStore]];
            });
        });
    });
});

SPEC_END
