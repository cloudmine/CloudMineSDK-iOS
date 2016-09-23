//
//  CMObjectSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
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
#import "CMWebService.h"
#import "CMUser.h"
#import "CMWebService.h"
#import "CMTestProtocolObject.h"

@interface CustomObject : CMObject
@property (nonatomic, retain) NSString *something;
@property (nonatomic, retain) NSString *somethingElse;
@end

@implementation CustomObject
@synthesize something, somethingElse;

- (instancetype)initWithCoder:(NSCoder *)coder {
    if(self = [super initWithCoder:coder]) {
        // Decode properties from coder
        self.something = [coder decodeObjectForKey:@"something"];
        self.somethingElse = [coder decodeObjectForKey:@"somethingElse"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    // Encode properties in coder
    [coder encodeObject:something forKey:@"something"];
    [coder encodeObject:somethingElse forKey:@"somethingElse"];
}


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
    
    it(@"should have a description", ^{
        CMTestProtocolObject *testing = [[CMTestProtocolObject alloc] init];
        [[[testing description] should] beNonNil];
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
            [obj save:nil];
            [[theValue([obj ownershipLevel]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[theBlock(^{ [obj saveAtUserLevel:nil]; }) should] raise];
        });
        
        it(@"should throw an exception if ACLs are added to the object", ^{
            CMACL *acl = [[CMACL alloc] init];
            [obj save:nil];
            [[theValue([obj ownershipLevel]) should] equal:theValue(CMObjectOwnershipAppLevel)];
            [[theBlock(^{ [obj addACL:acl callback:nil]; }) should] raise];
        });
        
        it(@"it should always belong to a store", ^{
            [[theValue([obj belongsToStore]) should] equal:@YES];
        });
        
        it(@"should properly make the objectId a string if not given a string", ^{
            NSDictionary *badDict = @{@"something": @"aValue", @"__id__" : @3424};
            CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:badDict];
            CustomObject *custom = [[CustomObject alloc] initWithCoder:decoder];
            [[custom.objectId should] equal:@"3424"];
            [[custom.something should] equal:@"aValue"];
        });
        
        it(@"should be equal to another object with the same id", ^{
            CMObject *obj = [[CMObject alloc] initWithObjectId:@"1"];
            CMObject *obj2 = [[CMObject alloc] initWithObjectId:@"1"];
            [[obj should] equal:obj2];
        });
        
        it(@"should not be equal if the two objects are different class though", ^{
            CMObject *obj = [[CMObject alloc] initWithObjectId:@"1"];
            CMUser *obj2 = [[CMUser alloc] init];
            [obj2 setValue:@"1" forKey:@"objectId"];
            [[obj shouldNot] equal:obj2];
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
        
        it(@"it should always belong to a store", ^{
            [[theValue([obj belongsToStore]) should] equal:@YES];
        });
        
        it(@"should be able to change stores", ^{
            
            CMStore *newStore = [CMStore store];
            newStore.user = [[CMUser alloc] init];
            newStore.user.token = @"1234";
            newStore.user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0];
            
            [newStore addUserObject:obj];
            [[obj.store should] equal:newStore];
            
            CMStore *another = [CMStore store];
            another.user = [[CMUser alloc] init];
            another.user.token = @"1234";
            another.user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0];
            
            [another addUserObject:obj];
            [[obj.store should] equal:another];
        });

    });

    context(@"given an object that doesn't belong to a store yet", ^{
        
        it(@"it should always belong to a store", ^{
            [[theValue([obj belongsToStore]) should] equal:@YES];
        });
        
        it(@"should save to the app-level when save: is called on the object", ^{
            [obj save:nil];
            [[theValue(obj.ownershipLevel) should] equal:theValue(CMObjectOwnershipAppLevel)];
        });

        it(@"should save to the user-level when saveWithUser: is called on the object", ^{
            CMUser *user = [[CMUser alloc] init];
            user.token = @"1234";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000.0]; // set it to the future

            [obj saveAtUserLevel:nil];
            [[theValue(obj.ownershipLevel) should] equal:theValue(CMObjectOwnershipUserLevel)];
        });
    });

    context(@"given an object that belongs to any store", ^{
        
        it(@"should be able to add an id to the __access__ array", ^{
            CMObject *obj = [[CMObject alloc] init];
            [obj addAclId:@"derp"];
            NSArray *acls = [obj valueForKey:@"aclIds"];
            [[acls should] haveLengthOf:1];
            [[acls[0] should] equal:@"derp"];
        });
        
        it(@"should set its store to the CMNullStore singleton when the store is set to nil", ^{
            CMObject *obj = [[CMObject alloc] init];
            [[obj.store should] equal:[CMStore defaultStore]];
            obj.store = nil;
            [[obj.store should] equal:[CMNullStore nullStore]];
            [[theValue(obj.ownershipLevel) should] equal:@(CMObjectOwnershipUndefinedLevel)];
        });
        
        it(@"should properly set the ownership level if being set to a different, but not null, store", ^{
            CMObject *obj = [[CMObject alloc] init];
            [[obj.store should] equal:[CMStore defaultStore]];
            
            CMStore *firstNewStore = [CMStore store];
            [firstNewStore addObject:obj];
            
            CMStore *newStore = [CMStore store];
            [newStore addObject:obj];
            
            [[theValue(obj.ownershipLevel) should] equal:@(CMObjectOwnershipAppLevel)];
            [[obj.store should] equal:newStore];
        });
        
        it(@"should properly set the ownership level if being set to a different, but not null, store for a user", ^{
            CMObject *obj = [[CMObject alloc] init];
            [[obj.store should] equal:[CMStore defaultStore]];
            
            CMUser *fakeUser = [[CMUser alloc] init];
            
            CMStore *firstNewStore = [CMStore store];
            firstNewStore.user = fakeUser;
            [firstNewStore addUserObject:obj];
            
            CMStore *newStore = [CMStore store];
            newStore.user = fakeUser;
            [newStore addUserObject:obj];
            
            [[theValue(obj.ownershipLevel) should] equal:@(CMObjectOwnershipUserLevel)];
            [[obj.store should] equal:newStore];
        });
        
        it(@"should properly set the ownership level if being set to a different, but not null, store without setting the obj first", ^{
            CMObject *obj = [[CMObject alloc] init];
            [[obj.store should] equal:[CMStore defaultStore]];
            
            CMStore *firstNewStore = [CMStore store];
            [firstNewStore addObject:obj];
            
            CMStore *newStore = [CMStore store];
            [obj setStore:newStore];
            
            [[theValue(obj.ownershipLevel) should] equal:@(CMObjectOwnershipAppLevel)];
            [[obj.store should] equal:newStore];
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
//            [[store should] receive:@selector(saveObject:additionalOptions:callback:)];
            KWCaptureSpy *spy = [(KWMock *)store.webService captureArgument:@selector(updateValuesFromDictionary:serverSideFunction:user:extraParameters:successHandler:errorHandler:) atIndex:4];
            
            [object save:^(CMObjectUploadResponse *response) { }];
            
            // Fabricate a successful upload response
            [object setValue:@"SomeIDReturnedByTheServer" forKey:@"objectId"];
            CMWebServiceObjectFetchSuccessCallback callback = (CMWebServiceObjectFetchSuccessCallback)spy.argument;
            callback([NSDictionary dictionaryWithObject:@"updated" forKey:object.objectId], nil, nil, nil, nil, nil);
            
            // The object should be marked as clean
            [[theValue(object.dirty) should] beNo];
        });
        
        it(@"should properly encode and decode nil", ^{
            object.something = nil;
            object.somethingElse = nil;
            
            NSDictionary *serializedObject = [CMObjectEncoder encodeObjects:@[object]];
            NSDictionary *result = [serializedObject valueForKey:@"SomeIDReturnedByTheServer"];
        
            [[[result valueForKey:@"something"] should] beIdenticalTo:[NSNull null]];
            [[[result valueForKey:@"somethingElse"] should] beIdenticalTo:[NSNull null]];
            
            object = [[CMObjectDecoder decodeObjects:serializedObject] lastObject];
            [object.something shouldBeNil];
            [object.somethingElse shouldBeNil];
        });
        
        it(@"should encode and decode null to <null>", ^{
            object.something = NULL;
            object.somethingElse = NULL;
            
            NSDictionary *serializedObject = [CMObjectEncoder encodeObjects:@[object]];
            NSDictionary *result = [serializedObject valueForKey:@"SomeIDReturnedByTheServer"];
            
            [[[result valueForKey:@"something"] should] beIdenticalTo:[NSNull null]];
            [[[result valueForKey:@"somethingElse"] should] beIdenticalTo:[NSNull null]];
            
            object = [[CMObjectDecoder decodeObjects:serializedObject] lastObject];
            [object.something shouldBeNil];
            [object.somethingElse shouldBeNil];
        });
        

    });
});

SPEC_END
