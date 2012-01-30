//
//  CMStoreSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMStore.h"
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
        [[CMAPICredentials sharedInstance] setApiKey:@"apikey"];
        [[CMAPICredentials sharedInstance] setAppKey:@"appkey"];
    });
    
    beforeEach(^{
        webService = [CMWebService mock];
    });

    context(@"given an app-level store", ^{
        beforeEach(^{
            store = [CMStore store];
            store.webService = webService;
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
                    NSLog(@"addy of obj's store is %p", obj.store);
                    [obj.store shouldBeNil];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
                }];
                [appObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:store];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
                }];
            });
        });
    });

//    
//    beforeEach(^{
//        webService = [CMWebService mock];
//        store = [CMStore store];
//        store.webService = webService;
//    });
//    
//    context(@"given no query or keys", ^{
//        it(@"should pass all objects to provided callback when the store is asked for all objects", ^{
//            NSMutableDictionary *webServiceResponse = [[NSMutableDictionary alloc] initWithCapacity:10];
//            NSMutableArray *allObjectsInResponse = [[NSMutableArray alloc] initWithCapacity:10];
//            for(int i=0; i<10; i++) {
//                CMGenericSerializableObject *obj = [[CMGenericSerializableObject alloc] init];
//                [obj fillPropertiesWithDefaults];
//                [webServiceResponse setObject:obj forKey:obj.objectId];
//                [allObjectsInResponse addObject:obj];
//            }
//            
//            id spy = [[CMBlockValidationMessageSpy alloc] init];
//            [spy addValidationBlock:^(NSInvocation *invocation) {
//                
//            } forSelector:@selector(getValuesForKeys:serverSideFunction:successHandler:errorHandler:)];
//            
//            [store allObjects:^(NSArray *objects) {
//                [[[objects should] have:10] items];
//                for (CMGenericSerializableObject *theObj in objects) {
//                    [[allObjectsInResponse should] contain:theObj];
//                }
//            }];
//        });
//        
//        context(@"given permission to use the local cache", ^{
//            pending(@"should not make a web call if objects exist in local cache", ^{
//                
//            });
//        });
//    });
//    
//    context(@"given a collection of keys to objects", ^{
//        pending(@"should return objects with those keys", ^{
//        });
//        
//        pending(@"should set error conditions for keys that don't exist server-side", ^{
//        });
//    });
//    
//    context(@"given a query to execute", ^{
//        pending(@"should execute it with a server request and return a collection of the objects", ^{
//        });
//        
//        context(@"given a server-side post-processing function", ^{
//            pending(@"should execute it and return a collection of those post-processed objects", ^{
//            });
//        });
//        
//        pending(@"should not send an HTTP request when a previously-issued query is re-issued", ^{
//        });
//    });
//    
//    context(@"given the key of a binary file", ^{
//        pending(@"should return the raw data of that file if it exists server-side", ^{
//        });
//        
//        pending(@"should return an error when the file doesn't exist server-side", ^{
//        });
//    });
//    
//    context(@"given a locally-created object", ^{
//        pending(@"should mark the object as unsaved", ^{
//        });
//    });
//    
//    context(@"when requested to save", ^{
//        context(@"when a particular, local-only object id is given", ^{
//            pending(@"should persist only that one object to the server and no longer consider it local-only", ^{
//            });
//        });
//        
//        context(@"when a particular, non-local-only object id is given", ^{
//            pending(@"should persist only that one object", ^{
//            }); 
//        });
//    });

});

SPEC_END