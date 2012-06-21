//
//  CMFileSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"
#import "NSMutableData+RandomData.h"

#import "CMFile.h"
#import "CMUser.h"
#import "CMAPICredentials.h"
#import "CMStore.h"
#import "CMWebService.h"
#import "CMNullStore.h"

SPEC_BEGIN(CMFileSpec)

describe(@"CMFile", ^{

    __block CMFile *file = nil;
    __block CMStore *store = nil;

    beforeEach(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"appId"];
        [[CMAPICredentials sharedInstance] setAppSecret:@"appSecret"];
    });

    context(@"given an app-level CMFile instance", ^{
        beforeEach(^{
            file = [[CMFile alloc] initWithData:[NSMutableData randomDataWithLength:100] named:@"foofile"];
            store = [CMStore defaultStore];
            store.webService = [CMWebService nullMock];
        });

        it(@"it should calculate the cache file location correctly", ^{
            NSString *uuid = [file valueForKey:@"uuid"];
            NSArray *cacheLocationPathComponents = [file.cacheLocation pathComponents];
            NSString *fileName = [cacheLocationPathComponents lastObject];
            NSString *fileParentDirectory = [cacheLocationPathComponents objectAtIndex:[cacheLocationPathComponents count] - 2];

            [[fileName should] equal:[NSString stringWithFormat:@"%@_foofile", uuid]];
            [[fileParentDirectory should] equal:@"cmFiles"];
        });

        it(@"should add itself to the new store and remove itself from the old one when a new store is assigned", ^{
            CMStore *newStore = [CMStore store];
            [[file.store should] equal:store];

            file.store = newStore;

            [[theValue([[CMStore defaultStore] objectOwnershipLevel:file]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [[theValue([newStore objectOwnershipLevel:file]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[file.store should] equal:newStore];
        });

        it(@"should save at the app level when save is called directly on the object", ^{
            [file save:nil];
            [[theValue([file ownershipLevel]) should] equal:theValue(CMObjectOwnershipAppLevel)];
        });

        it(@"should throw an exception if the object is subsequently saved with a user", ^{
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@test.com" andPassword:@"pass"];
            [file save:nil];
            [[theValue([file ownershipLevel]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[theBlock(^{ [file saveWithUser:user callback:nil]; }) should] raise];
        });
    });

    context(@"given a user-level CMFile instance", ^{
        beforeEach(^{
            [[CMAPICredentials sharedInstance] setAppIdentifier:@"appid1234"];
            [[CMAPICredentials sharedInstance] setAppSecret:@"appsecret1234"];

            store = [CMStore defaultStore];
            store.webService = [CMWebService nullMock];

            CMUser *user = [[CMUser alloc] initWithUserId:@"uid" andPassword:@"pw"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:9999];
            file = [[CMFile alloc] initWithData:[NSMutableData randomDataWithLength:100]
                                          named:@"foofile"
                                       mimeType:nil];

            store.user = user;
            [store addUserFile:file];
        });

        it(@"it should calculate the cache file location correctly", ^{
            NSString *uuid = [file valueForKey:@"uuid"];
            NSArray *cacheLocationPathComponents = [file.cacheLocation pathComponents];
            NSString *fileName = [cacheLocationPathComponents lastObject];
            NSString *fileParentDirectory = [cacheLocationPathComponents objectAtIndex:[cacheLocationPathComponents count] - 2];

            [[fileName should] equal:[NSString stringWithFormat:@"%@_foofile", uuid]];
            [[fileParentDirectory should] equal:@"cmUserFiles"];
        });

        it(@"should save at the user level when save is called directly on the object", ^{
            CMUser *user = [[CMUser alloc] init];
            user.token = @"1234";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0]; // set it to the future

            store.user = user;
            [store addUserFile:file];

            [file save:nil];
            [[theValue(file.ownershipLevel) should] equal:theValue(CMObjectOwnershipUserLevel)];
        });
    });

    context(@"given a file that doesn't belong to a store yet", ^{
        beforeEach(^{
            file = [[CMFile alloc] initWithData:[NSMutableData randomDataWithLength:100] named:@"foofile"];
            store = [CMStore defaultStore];
            store.webService = [CMWebService nullMock];
        });

        it(@"should save to the app-level when save: is called on the object", ^{
            [file save:nil];
            [[theValue(file.ownershipLevel) should] equal:theValue(CMObjectOwnershipAppLevel)];
        });

        it(@"should save to the user-level when saveWithUser: is called on the object", ^{
            CMUser *user = [[CMUser alloc] init];
            user.token = @"1234";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0]; // set it to the future

            [file saveWithUser:user callback:nil];
            [[theValue(file.ownershipLevel) should] equal:theValue(CMObjectOwnershipUserLevel)];
        });
    });

    context(@"given a file that belongs to any store", ^{
        it(@"should set its store to the CMNullStore singleton when the store is set to nil", ^{
            CMFile *file = [[CMFile alloc] initWithData:NULL named:@"foo"];
            [[file.store should] equal:[CMStore defaultStore]];
            file.store = nil;
            [[file.store should] equal:[CMNullStore nullStore]];
        });
    });
});

SPEC_END
