//
//  CMStoreSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMStore.h"
#import "CMACL.h"
#import "CMNullStore.h"
#import "CMWebService.h"
#import "CMGenericSerializableObject.h"
#import "CMAPICredentials.h"
#import "CMBlockValidationMessageSpy.h"
#import "CMAppDelegateBase.h"
#import "TestUser.h"
#import "Venue.h"

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
        
        it(@"should have no error to start out", ^{
            [[store.lastError should] beNil];
        });
        
        it(@"should be able to change the base URL of the webservice", ^{
            CMStore *newStore = [CMStore storeWithBaseURL:@"http://www.example.com"];
            [[newStore.webService.baseURL.absoluteString should] equal:@"http://www.example.com"];
        });
        
        it(@"should have a user and a different base url", ^{
            CMUser *newUser = [[CMUser alloc] initWithUsername:@"username" andPassword:@"password"];
            CMStore *newStore = [CMStore storeWithUser:newUser baseURL:@"http://www.example.com"];
            [[newStore.webService.baseURL.absoluteString should] equal:@"http://www.example.com"];
            [[newStore.user should] beNonNil];
        });
        

        it(@"should nullify the object's store reference when removed from the store", ^{
            CMObject *obj = [[CMObject alloc] init];
            [store addObject:obj];

            [store removeObject:obj];
            [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [[obj.store should] equal:[CMNullStore nullStore]];
        });
        
        it(@"should return an error for getting objects if the webservice has an issue", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(getValuesForKeys:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:) atIndex:7];
            [[store.webService should] receive:@selector(getValuesForKeys:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store objectsWithKeys:@[@"akey"] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];

        });
        
        it(@"should return an error for saving a file if the webserver has issues", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(uploadFileAtPath:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:) atIndex:7];
            [[store.webService should] receive:@selector(uploadFileAtPath:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            NSURL *url = [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"]];
            // This first call should trigger the web service call.
            [store saveFileAtURL:url additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should return an error for saving a file(data) if the webserver has issues", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(uploadBinaryData:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:) atIndex:7];
            [[store.webService should] receive:@selector(uploadBinaryData:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            NSData *data = [[NSData alloc] init];
            // This first call should trigger the web service call.
            [store saveFileWithData:data additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should return an error for deleting a file", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(deleteValuesForKeys:serverSideFunction:user:extraParameters:successHandler:errorHandler:) atIndex:5];
            [[store.webService should] receive:@selector(deleteValuesForKeys:serverSideFunction:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store deleteFileNamed:@"name" additionalOptions:nil callback:^(CMDeleteResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should return an error for deleting a file", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(deleteValuesForKeys:serverSideFunction:user:extraParameters:successHandler:errorHandler:) atIndex:5];
            [[store.webService should] receive:@selector(deleteValuesForKeys:serverSideFunction:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store deleteObjects:@[[CMObject new]] additionalOptions:nil callback:^(CMDeleteResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should return an error for fetching a file", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(getBinaryDataNamed:serverSideFunction:user:extraParameters:successHandler:errorHandler:) atIndex:5];
            [[store.webService should] receive:@selector(getBinaryDataNamed:serverSideFunction:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store fileWithName:@"something" additionalOptions:nil callback:^(CMFileFetchResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should return an error for searching objects", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(searchValuesFor:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:) atIndex:7];
            [[store.webService should] receive:@selector(searchValuesFor:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store searchObjects:@"[__class__=\"Venue\"]" additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should return an error for saving objects", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(updateValuesFromDictionary:serverSideFunction:user:extraParameters:successHandler:errorHandler:) atIndex:5];
            [[store.webService should] receive:@selector(updateValuesFromDictionary:serverSideFunction:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store saveObject:[CMObject new] additionalOptions:nil callback:^(CMObjectUploadResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should guess the mime type from the name if no url is given", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(uploadBinaryData:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:) atIndex:3];
            [[store.webService should] receive:@selector(uploadBinaryData:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store saveFileWithData:[NSData new] named:@"file.png" additionalOptions:nil callback:^(CMFileUploadResponse *response) {

            }];
            
            NSString *mime = callbackBlockSpy.argument;
            [[mime should] equal:@"image/png"];
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
                [[theBlock(^{ [store addUserObject:obj]; }) should] raiseWithName:NSInternalInconsistencyException];
            });
            
            it(@"should raise an exception when an ACL is added", ^{
                CMACL *acl = [[CMACL alloc] init];
                [[theBlock(^{ [store addACL:acl]; }) should] raiseWithName:NSInternalInconsistencyException];
            });
        });
    });

    context(@"given a user-level store", ^{
        beforeEach(^{
            user = [[CMUser alloc] initWithEmail:@"userid@test.com" andPassword:@"password"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000];
            store = [CMStore storeWithUser:user];
            store.webService = webService;
            [store setValue:nil forKey:@"lastError"];
        });

        it(@"should nullify the object's store reference when removed from the store", ^{
            CMObject *obj = [[CMObject alloc] init];
            [store addUserObject:obj];

            [store removeUserObject:obj];
            [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
            [[obj.store should] equal:[CMNullStore nullStore]];
        });
        
        it(@"should return the proper error for getting ACL's", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(getACLsForUser:successHandler:errorHandler:) atIndex:2];
            [[store.webService should] receive:@selector(getACLsForUser:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store allACLs:^(CMACLFetchResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];

            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should return the proper error for getting ACL's", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(searchACLs:user:successHandler:errorHandler:) atIndex:3];
            [[store.webService should] receive:@selector(searchACLs:user:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store searchACLs:@"query" callback:^(CMACLFetchResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(CMErrorServerConnectionFailed)];
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            [[store.lastError shouldNot] beNil];
        });
        
        it(@"should return a 401 when getting ACL's for a not logged in user", ^{
            
            [[store.webService shouldNot] receive:@selector(getACLsForUser:successHandler:errorHandler:)];

            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:@{NSLocalizedDescriptionKey: @"The request was unauthorized. Is your API key correct?"}];
            store.user.tokenExpiration = nil;
            // This first call should trigger the web service call.
            [store allACLs:^(CMACLFetchResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(error.code)];
                [[response.error.domain should] equal:error.domain];
            }];
            
            [[store.lastError should] beNil];
        });
        
        it(@"should return a 401 when getting user objects for a not logged in user", ^{
            [[store.webService shouldNot]
             receive:@selector(getValuesForKeys:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:)];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:@{NSLocalizedDescriptionKey: @"The request was unauthorized. Is your API key correct?"}];
            store.user.tokenExpiration = nil;
            // This first call should trigger the web service call.
            [store userObjectsWithKeys:@[@"objectkey"] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
                [[response.error shouldNot] beNil];
                [[theValue(response.error.code) should] equal:@(error.code)];
                [[response.error.domain should] equal:error.domain];
            }];
            
            [[store.lastError should] beNil];
        });
        
        it(@"should fail to delete ACL's when none are passed", ^{
            
            [[store.webService shouldNot] receive:@selector(deleteACLWithKey:user:successHandler:errorHandler:)];
            
            [store deleteACLs:@[] callback:^(CMDeleteResponse *response) {
            }];
            
            [[store.lastError should] beNil];
        });

#warning The following 2 tests expose an issue with error handling when working with ACLs
// Note the actual expected values in the comments below; see https://jira.cloudmine.me/browse/CM-3969 for a detailed explanation
        it(@"should return the proper error when saving ACL's", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(updateACL:user:successHandler:errorHandler:) atIndex:3];
            [[store.webService should] receive:@selector(updateACL:user:successHandler:errorHandler:) withCount:1];
            
            // This first call should trigger the web service call.
            [store saveACLs:@[[CMACL new]] callback:^(CMObjectUploadResponse *response) {
                [[response.error should] beNil]; // should not be nil
                [[theValue(response.error.code) should] beZero];
                [[response.uploadStatuses should] haveCountOf:1]; // should be zero
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);

            [[store.lastError should] beNil]; // should be the error created above
        });
        
        it(@"should return the proper error when deleting ACL's", ^{
            KWCaptureSpy *callbackBlockSpy = [store.webService
                                              captureArgument:@selector(deleteACLWithKey:user:successHandler:errorHandler:) atIndex:3];
            [[store.webService should] receive:@selector(deleteACLWithKey:user:successHandler:errorHandler:) withCount:1];

            // This first call should trigger the web service call.
            [store deleteACLs:@[[CMACL new]] callback:^(CMDeleteResponse *response) {
                [[response.error should] beNil]; // should not be nil
                [[theValue(response.error.code) should] beZero];
                [[response.objectErrors should] haveCountOf:1]; // should be zero
            }];
            
            NSError *error = [NSError errorWithDomain:CMErrorDomain
                                                 code:CMErrorServerConnectionFailed
                                             userInfo:@{NSLocalizedDescriptionKey: @"A connection to the server was not able to be established."}];
            
            CMWebServiceFetchFailureCallback callback = callbackBlockSpy.argument;
            callback(error);
            
            [[store.lastError should] beNil]; // should be the error created above
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
            
            it(@"should be user-level when an ACL is added to the store", ^{
                CMACL *acl = [[CMACL alloc] init];
                [store addACL:acl];
                [[theValue([store objectOwnershipLevel:acl]) should] equal:theValue(CMObjectOwnershipUserLevel)];
                [[acl.store should] equal:store];
            });
            
            it(@"should assert that the delegate is a CMAppBase", ^{
                [[theBlock(^{ [store registerForPushNotificationTypes:UIUserNotificationTypeAlert callback:nil]; }) should] raise];
            });
            
            it(@"should let the user unregister for push notifications", ^{

                KWCaptureSpy *callbackBlockSpy = [store.webService captureArgument:@selector(unRegisterForPushNotificationsWithUser:callback:) atIndex:1];
                [[store.webService should] receive:@selector(unRegisterForPushNotificationsWithUser:callback:) withCount:1];
                
                // This first call should trigger the web service call.
                [store unRegisterForPushNotificationsWithCallback:^(CMDeviceTokenResult result) {
                    [[@(result) should] equal:@(CMDeviceTokenDeleted)];
                }];
                
                CMWebServiceDeviceTokenCallback callback = callbackBlockSpy.argument;
                callback(CMDeviceTokenDeleted);
            });
            
        });

        context(@"when performing a remote operation", ^{
            it(@"should not log the user in if they aren't already logged in before saving an object", ^{
                CMObject *obj = [[CMObject alloc] init];
                [[user should] receive:@selector(isLoggedIn)];
                [[user shouldNot] receive:@selector(loginWithCallback:)];
                [webService captureArgument:@selector(updateValuesFromDictionary:serverSideFunction:user:extraParameters:successHandler:errorHandler:) atIndex:0];
                [store saveUserObject:obj callback:nil];
            });

            it(@"should not log the user in if they aren't already logged in before deleting an object", ^{
                CMObject *obj = [[CMObject alloc] init];
                [[user should] receive:@selector(isLoggedIn)];
                [[user shouldNot] receive:@selector(loginWithCallback:)];
                [webService captureArgument:@selector(deleteValuesForKeys:serverSideFunction:user:extraParameters:successHandler:errorHandler:) atIndex:0];
                [store deleteUserObject:obj additionalOptions:nil callback:nil];
            });

            it(@"should not log the user in if they aren't already logged in before searching for objects", ^{
                [[user should] receive:@selector(isLoggedIn)];
                [[user shouldNot] receive:@selector(loginWithCallback:)];
                [webService captureArgument:@selector(getValuesForKeys:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:) atIndex:0];
                [store searchUserObjects:@"" additionalOptions:nil callback:nil];
            });

            it(@"should not log the user in if they aren't already logged in before getting objects by key", ^{
                [[user should] receive:@selector(isLoggedIn)];
                [[user shouldNot] receive:@selector(loginWithCallback:)];
                [webService captureArgument:@selector(getValuesForKeys:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:) atIndex:0];
                [store allUserObjectsWithOptions:nil callback:nil];
            });
            
            it(@"should not log the user in if they aren't already logged in before saving an ACL", ^{
                CMACL *acl = [[CMACL alloc] init];
                [[user should] receive:@selector(isLoggedIn)];
                [[user shouldNot] receive:@selector(loginWithCallback:)];
                [webService captureArgument:@selector(updateACL:user:successHandler:errorHandler:) atIndex:0];
                [store saveACL:acl callback:nil];
            });
            
            it(@"should not log the user in if they aren't already logged in before deleting an ACLs", ^{
                CMACL *acl = [[CMACL alloc] init];
                [[user should] receive:@selector(isLoggedIn)];
                [[user shouldNot] receive:@selector(loginWithCallback:)];
                [webService captureArgument:@selector(deleteACLWithKey:user:successHandler:errorHandler:) atIndex:0];
                [store deleteACL:acl callback:nil];
            });
            
            it(@"should not log the user in if they aren't already logged in before searching for ACLs", ^{
                [[user should] receive:@selector(isLoggedIn)];
                [[user shouldNot] receive:@selector(loginWithCallback:)];
                [webService captureArgument:@selector(searchACLs:user:successHandler:errorHandler:) atIndex:0];
                [store searchACLs:@"" callback:nil];
            });
            
            it(@"should not log the user in if they aren't already logged in before getting all ACLs", ^{
                [[user should] receive:@selector(isLoggedIn)];
                [[user shouldNot] receive:@selector(loginWithCallback:)];
                [webService captureArgument:@selector(getACLsForUser:successHandler:errorHandler:) atIndex:0];
                [store allACLs:nil];
            });
            
        });

        context(@"when changing user ownership of a store", ^{
            it(@"should nullify store relationships with user-level objects stored under the previous user", ^{
                NSMutableArray *userObjects = [NSMutableArray arrayWithCapacity:5];
                NSMutableArray *appObjects = [NSMutableArray arrayWithCapacity:5];
                NSMutableArray *aclObjects = [NSMutableArray arrayWithCapacity:5];
                for (int i=0; i<5; i++) {
                    CMObject *userObject = [[CMObject alloc] init];
                    CMObject *appObject = [[CMObject alloc] init];
                    CMACL *acl = [[CMACL alloc] init];
                    [userObjects addObject:userObject];
                    [appObjects addObject:appObject];
                    [aclObjects addObject:acl];
                    [store addACL:acl];
                    [store addUserObject:userObject];
                    [store addObject:appObject];
                }

                // Validate that all the objects have been configured properly.
                [aclObjects enumerateObjectsUsingBlock:^(CMACL *acl, NSUInteger idx, BOOL *stop) {
                    [[acl.store should] equal:store];
                    [[theValue([store objectOwnershipLevel:acl]) should] equal:theValue(CMObjectOwnershipUserLevel)];
                }];
                [userObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:store];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUserLevel)];
                }];
                [appObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:store];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
                }];

                // Now change the store user and re-validate.
                CMUser *theOtherUser = [[CMUser alloc] initWithEmail:@"somethingelse@test.com" andPassword:@"foobar"];
                store.user = theOtherUser;
                [aclObjects enumerateObjectsUsingBlock:^(CMACL *acl, NSUInteger idx, BOOL *stop) {
                    [[acl.store should] equal:[CMNullStore nullStore]];
                    [[theValue([store objectOwnershipLevel:acl]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
                }];
                [userObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:[CMNullStore nullStore]];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipUndefinedLevel)];
                }];
                [appObjects enumerateObjectsUsingBlock:^(CMObject *obj, NSUInteger idx, BOOL *stop) {
                    [[obj.store should] equal:store];
                    [[theValue([store objectOwnershipLevel:obj]) should] equal:theValue(CMObjectOwnershipAppLevel)];
                }];
            });
            
            it(@"should not change object ownership when setting the same user", ^{
                CMStore *store = [CMStore store];
                TestUser *user = [[TestUser alloc] initWithEmail:@"test@testing.com" andPassword:@"test"];
                [store setUser:user];
                Venue *venue = [Venue new];
                [store addUserObject:venue];
                user.aVenue = venue;
                
                [[theValue([user.aVenue ownershipLevel]) should] equal:theValue(CMObjectOwnershipUserLevel)];
                [store setUser:user];
                [[theValue([user.aVenue ownershipLevel]) should] equal:theValue(CMObjectOwnershipUserLevel)];
            });
            
        });
    });
});

SPEC_END
