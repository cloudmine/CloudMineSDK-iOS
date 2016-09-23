//
//  CMFileSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
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
#import "CMObjectEncoder.h"

SPEC_BEGIN(CMFileSpec)

describe(@"CMFile", ^{

    __block CMFile *file = nil;
    __block CMStore *store = nil;

    beforeEach(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"appId"];
        [[CMAPICredentials sharedInstance] setApiKey:@"appSecret"];
    });

    context(@"given an app-level CMFile instance", ^{
        beforeEach(^{
            file = [[CMFile alloc] initWithData:[NSMutableData randomDataWithLength:100] named:@"foofile"];
            store = [CMStore defaultStore];
            store.webService = [CMWebService nullMock];
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
        
        it(@"should default the mimetype to 'application/octet-stream'", ^{
            [[file.mimeType should] equal:@"application/octet-stream"];
        });
        
        it(@"should throw an exception when calling className", ^{
            [[theBlock(^{ [[file class] className]; }) should] raise];
        });
        
        it(@"should have an objectId equal to it's name", ^{
            [[file.objectId should] equal:@"foofile"];
        });
        
        it(@"should have no user associated with it", ^{
            [[file.user should] beNil];
        });
        
        it(@"should properly show the user level (even though it's deprecated)", ^{
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[theValue([file isUserLevel]) should] equal:@NO];
            #pragma clang diagnostic pop
        });
        
        it(@"should create the same CMFile if you call the deprecated method", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            CMFile *newFile = [[CMFile alloc] initWithData:[NSMutableData randomDataWithLength:100]
                                                     named:@"foofile"
                                           belongingToUser:nil
                                                  mimeType:@"application/octet-stream"];
#pragma clang diagnostic pop
            
            [[newFile.objectId should] equal:file.objectId];
            [[newFile.mimeType should] equal:file.mimeType];
            [[newFile.fileName should] equal:file.fileName];
            [[newFile.fileData shouldNot] beNil];
            //Data is random, so won't equal each other
            
        });
        

        it(@"should throw an exception if the object is subsequently saved with a user", ^{
            [file save:nil];
            [[theValue([file ownershipLevel]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[theBlock(^{ [file saveAtUserLevel:nil]; }) should] raise];
        });
    });
    
    context(@"given a CMFile loaded with a real file", ^{
        
        __block CMFile *realFile = nil;
        __block NSString *fileName = @"cloudmine.png";
        
        beforeEach(^{
            NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            NSData *data = UIImagePNGRepresentation(image);
            realFile = [[CMFile alloc] initWithData:data named:fileName mimeType:@"image/png"];
        });
        
        it(@"should properly have all the file information", ^{
            
            NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            NSData *data = UIImagePNGRepresentation(image);
            
            [[realFile.mimeType should] equal:@"image/png"];
            [[realFile.fileData should] equal:data];
            [[realFile.fileName should] equal:fileName];
            [[realFile.objectId should] equal:fileName];
        });
        
        it(@"should be encoded and decoded properly", ^{
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:realFile];
            CMFile *remade = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            NSData *fileData = UIImagePNGRepresentation(image);
            
            [[remade.mimeType should] equal:@"image/png"];
            [[remade.fileData should] equal:fileData];
            [[remade.fileName should] equal:fileName];
            [[remade.objectId should] equal:fileName];
        });
        
        it(@"should properly get the object from the cache", ^{
            //uhhhh.... what.
        });
        
    });

    context(@"given a user-level CMFile instance", ^{
        beforeEach(^{
            [[CMAPICredentials sharedInstance] setAppIdentifier:@"appid1234"];
            [[CMAPICredentials sharedInstance] setApiKey:@"appsecret1234"];

            store = [CMStore defaultStore];
            store.webService = [CMWebService nullMock];

            CMUser *user = [[CMUser alloc] initWithEmail:@"uid" andPassword:@"pw"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:9999];
            file = [[CMFile alloc] initWithData:[NSMutableData randomDataWithLength:100]
                                          named:@"foofile"
                                       mimeType:nil];

            store.user = user;
            [store addUserFile:file];
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

            [file saveAtUserLevel:nil];
            [[theValue(file.ownershipLevel) should] equal:theValue(CMObjectOwnershipUserLevel)];
        });
    });

    context(@"given a file that belongs to any store", ^{
        it(@"should set its store to the CMNullStore singleton when the store is set to nil", ^{
            CMFile *file = [[CMFile alloc] initWithData:NULL named:@"foo"];
            [[file.store should] equal:[CMStore defaultStore]];
            file.store = nil;
            [[file.store should] equal:[CMNullStore nullStore]];
            [[theValue(file.ownershipLevel) should] equal:@(CMObjectOwnershipUndefinedLevel)];
        });
        
        it(@"should properly set the ownership level", ^{
            CMFile *file = [[CMFile alloc] initWithData:nil named:@"foo"];
            [[file.store should] equal:[CMStore defaultStore]];
            file.store = nil;
            [[file.store should] equal:[CMNullStore nullStore]];
            file.store = [CMStore defaultStore];
            [[file.store should] equal:[CMStore defaultStore]];
        });
        
        it(@"should properly set the ownership level if being set to a different, but not null, store", ^{
            CMFile *file = [[CMFile alloc] initWithData:nil named:@"foo"];
            [[file.store should] equal:[CMStore defaultStore]];
            
            CMStore *firstNewStore = [CMStore store];
            [firstNewStore addFile:file];
            
            CMStore *newStore = [CMStore store];
            [newStore addFile:file];
            
            [[theValue(file.ownershipLevel) should] equal:@(CMObjectOwnershipAppLevel)];
            [[file.store should] equal:newStore];
            NSDictionary *cached = [firstNewStore valueForKey:@"_cachedAppFiles"];
            [[cached shouldNot] beNil];
            [[cached[file.uuid] should] beNil];
        });
        
        it(@"should properly set the ownership level if being set to a different, but not null, store for a user", ^{
            CMFile *file = [[CMFile alloc] initWithData:nil named:@"foo"];
            [[file.store should] equal:[CMStore defaultStore]];
            
            CMUser *fakeUser = [[CMUser alloc] init];
            
            CMStore *firstNewStore = [CMStore store];
            firstNewStore.user = fakeUser;
            [firstNewStore addUserFile:file];
            
            CMStore *newStore = [CMStore store];
            newStore.user = fakeUser;
            [newStore addUserFile:file];
            
            [[theValue(file.ownershipLevel) should] equal:@(CMObjectOwnershipUserLevel)];
            [[file.store should] equal:newStore];
            NSDictionary *cached = [firstNewStore valueForKey:@"_cachedUserFiles"];
            [[cached shouldNot] beNil];
            [[cached[file.uuid] should] beNil];

        });
        
        it(@"should properly set the ownership level if being set to a different, but not null, store without setting the file first", ^{
            CMFile *file = [[CMFile alloc] initWithData:nil named:@"foo"];
            [[file.store should] equal:[CMStore defaultStore]];

            CMStore *firstNewStore = [CMStore store];
            [firstNewStore addFile:file];
            
            CMStore *newStore = [CMStore store];
            [file setStore:newStore];
            
            [[theValue(file.ownershipLevel) should] equal:@(CMObjectOwnershipAppLevel)];
            [[file.store should] equal:newStore];
        });
    });
});

SPEC_END
