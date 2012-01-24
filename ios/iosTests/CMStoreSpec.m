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

//SPEC_BEGIN(CMStoreSpec)
//
//describe(@"CMStore", ^{
//    __block CMWebService *webService = nil;
//    __block CMStore *store = nil;
//    
//    beforeAll(^{
//        [[CMAPICredentials sharedInstance] setApiKey:@"apikey"];
//        [[CMAPICredentials sharedInstance] setAppKey:@"appkey"];
//    });
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
//});
//
//SPEC_END