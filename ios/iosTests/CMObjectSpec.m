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
#import "CMACL.h"
#import "CMObjectDecoder.h"
#import "CMObjectEncoder.h"
#import "CMAPICredentials.h"
#import "CMUser.h"
#import "CMWebService.h"

@interface CustomObject : CMObject
@property (nonatomic, retain) NSString *something;
@property (nonatomic, retain) NSString *somethingElse;
@end

@implementation CustomObject
@synthesize something, somethingElse;
@end

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
        
        it(@"should throw an exception if ACLs are added to the object", ^{
            CMACL *acl = [[CMACL alloc] init];
            [obj save:nil];
            [[theValue([obj ownershipLevel]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[theBlock(^{ [obj addACL:acl callback:nil]; }) should] raise];
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
    
    
    context(@"given an object that is a custom subclass", ^{
        __block CustomObject *object = nil;
        __block CMStore *store = store;
        
        beforeAll(^{
            object = [[CustomObject alloc] init];
            store = [CMStore defaultStore];
            store.webService = [CMWebService nullMock];
        });
        
        it(@"should be dirty, seeing as I am the one who initialized it", ^{
            [[theValue(object.dirty) should] beYes];
        });
        
        it(@"should become clean if it is encoded and then decoded with CMObjectDecoder", ^{
            [[theValue(object.dirty) should] beYes];
            
            // Encode and decode the object, and ensure it went correctly
            NSString *objectId = object.objectId;
            object = [[CMObjectDecoder decodeObjects:[CMObjectEncoder encodeObjects:[NSArray arrayWithObject:object]]] lastObject];
            [[object.objectId should] equal:objectId];
            
            // It should be clean, because it was decoded with CMObjectDecoder
            [[theValue(object.dirty) should] beNo];
        });
        
        
        it(@"should become dirty if properties are changed and no other object changes have occured server-side", ^{
            [[theValue(object.dirty) should] beNo];
            
            // Changing the value of a property should make the object dirty
            object.something = @"Something important!";
            
            [[theValue(object.dirty) should] beYes];
        });
        
        it(@"should clean itself after it is successfully uploaded by CMStore", ^{
            [[theValue(object.dirty) should] beYes];
                        
            // Prepare spy and wait for message
            [[store should] receive:@selector(saveObject:additionalOptions:callback:)];
            KWCaptureSpy *spy = [(KWMock *)store.webService captureArgument:@selector(updateValuesFromDictionary:serverSideFunction:user:extraParameters:successHandler:errorHandler:) atIndex:4];
            
            [object save:^(CMObjectUploadResponse *response) { }];
            
            // Fabricate a successful upload response
            [object setValue:@"SomeIDReturnedByTheServer" forKey:@"objectId"];
            CMWebServiceObjectFetchSuccessCallback callback = (CMWebServiceObjectFetchSuccessCallback)spy.argument;
            callback([NSDictionary dictionaryWithObject:@"updated" forKey:object.objectId], nil, nil, nil, nil, nil);
            
            // The object should be marked as clean
            [[theValue(object.dirty) should] beNo];
        });

    });
});

SPEC_END
