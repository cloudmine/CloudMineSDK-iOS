//
//  CMStoreIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMStore.h"
#import "Venue.h"
#import "CMTestMacros.h"

SPEC_BEGIN(CMStoreIntegrationSpec)

describe(@"CMStoreIntegration", ^{
    
    __block CMStore *store = nil;
    __block NSArray *venues = nil;
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:APP_ID];
        [[CMAPICredentials sharedInstance] setApiKey:API_KEY];
        [[CMAPICredentials sharedInstance] setBaseURL:BASE_URL];
        
        store = [CMStore store];
        
        NSArray *data = [[NSDictionary dictionaryWithContentsOfFile:
                          [[NSBundle bundleForClass:[self class]]
                           pathForResource:@"venues" ofType:@"plist"]]
                         objectForKey:@"items"];
        
        NSMutableArray *loadedVenues = [NSMutableArray array];
        
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Venue *venue = [[Venue alloc] initWithDictionary:obj];
            [loadedVenues addObject:venue];
        }];
        
        venues = [NSArray arrayWithArray:loadedVenues];
    });
    
    it(@"should allow the creation of an object", ^{
        __block CMObjectUploadResponse *res = nil;
        [store saveObject:venues[0] callback:^(CMObjectUploadResponse *response) {
            res = response;
        }];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.snippetResult.data) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        [[expectFutureValue(res.uploadStatuses) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
    });
    
    it(@"should allow the creation of another object and running a snippet", ^{
        
        __block CMObjectUploadResponse *res = nil;
        CMServerFunction *serverFunction = [[CMServerFunction alloc] initWithFunctionName:@"store_integration"
                                                                          extraParameters:nil
                                                               responseContainsResultOnly:NO
                                                                    performAsynchronously:NO];
        
        CMStoreOptions *options = [[CMStoreOptions alloc] initWithServerSideFunction:serverFunction];
        
        [store saveObject:venues[1] additionalOptions:options callback:^(CMObjectUploadResponse *response) {
            res = response;
        }];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.snippetResult) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.snippetResult.data[@"store"]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"integration"];
        [[expectFutureValue(res.uploadStatuses) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
    });
    
    it(@"should be able to delete the venues", ^{
        __block CMDeleteResponse *res = nil;
        [store deleteObjects:@[venues[0], venues[1]] additionalOptions:nil callback:^(CMDeleteResponse *response) {
            res = response;
        }];
        
        NSString *objectId1 = [venues[0] objectId];
        NSString *objectId2 = [venues[0] objectId];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.success) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:2];
        [[expectFutureValue(res.success[objectId1]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"deleted"];
        [[expectFutureValue(res.success[objectId2]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"deleted"];
        [[expectFutureValue(res.objectErrors) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
    });
    
    it(@"should be able to save all objects", ^{
        
        Venue *v = venues[0];
        [v setValue:@YES forKey:@"dirty"];
        [[theValue(v.dirty) should] beTrue];
        
        Venue *v1 = venues[1];
        [v1 setValue:@YES forKey:@"dirty"];
        [[theValue(v1.dirty) should] beTrue];
        
        [store addObject:v];
        [store addObject:v1];
        
        __block CMObjectUploadResponse * res = nil;
        [store saveAll:^(CMObjectUploadResponse *response) {
            res = response;
        }];
        
        NSString *objectId1 = [venues[0] objectId];
        NSString *objectId2 = [venues[1] objectId];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.uploadStatuses) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:2];
        [[expectFutureValue(res.uploadStatuses[objectId1]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"created"];
        [[expectFutureValue(res.uploadStatuses[objectId2]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"created"];
    });

    it(@"should not throw an error if you try to save a nil object", ^{
        [[theBlock(^{
            CMObject *nilObject = nil;
            [store saveObject:nilObject callback:^(CMObjectUploadResponse *response) {

            }];
        }) shouldNot] raise];
    });
    
    it(@"should throw an error if you try and save a user without a user configured", ^{
        [[theBlock(^{
            [store saveUserObject:venues[2] callback:^(CMObjectUploadResponse *response) {}];
        }) should] raise];
    });
    
    it(@"should upload a file from a URL", ^{
        NSURL *url = [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"]];
        
        __block CMFileUploadResponse *res = nil;
        [store saveFileAtURL:url additionalOptions:nil callback:^(CMFileUploadResponse *response) {
            res = response;
        }];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.key) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(theValue(res.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMFileCreated)];
    });
    
    __block NSString *nonUserKey = @"app_icon_something";
    it(@"should upload a file with a given key", ^{
        NSURL *url = [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"]];
        
        __block CMFileUploadResponse *res = nil;
        [store saveFileAtURL:url named:nonUserKey additionalOptions:nil callback:^(CMFileUploadResponse *response) {
            res = response;
        }];

        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.key) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:nonUserKey];
        [[expectFutureValue(theValue(res.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMFileCreated)];
    });
    
    it(@"should fetch all the objects", ^{
        __block CMObjectFetchResponse *res = nil;
        [store allObjectsWithOptions:nil callback:^(CMObjectFetchResponse *response) {
            res = response;
            [[ theValue([res.objects containsObject:venues[0]]) should] beTrue];
            [[ theValue([res.objects containsObject:venues[1]]) should] beTrue];
        }];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.objects) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOfAtLeast:2];
    });
    
    it(@"should fetch the obejcts by key", ^{
        Venue *v0 = venues[0];
        Venue *v1 = venues[1];
        
        __block CMObjectFetchResponse *res = nil;
        [store objectsWithKeys:@[v0.objectId, v1.objectId] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
            res = response;
            
            [[res.objects should] contain:v0];
            [[res.objects should] contain:v1];
        }];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.objects) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:2];
    });
    
    it(@"should fetch all objects if the query is not specified", ^{
        
        Venue *v0 = venues[0];
        Venue *v1 = venues[1];
        
        __block CMObjectFetchResponse *res = nil;
        [store searchObjects:nil additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
            res = response;
            [[res.objects should] contain:v0];
            [[res.objects should] contain:v1];
        }];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.objects) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOfAtLeast:2];
    });
    
    it(@"should delete an object", ^{
        Venue *v1 = venues[1];
        
        __block CMDeleteResponse *res = nil;
        [store deleteObject:v1 additionalOptions:nil callback:^(CMDeleteResponse *response) {
            res = response;
        }];
        
        [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(res.success) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
    });
    
    context(@"with a CMUser", ^{
        
        beforeAll(^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"cmwebservice_integration@test.com" andPassword:@"testing"];
            __block CMUserAccountResult code = NSNotFound;
            [user createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                [store setUser:user];
            }];
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMUserAccountLoginSucceeded)];
        });
        
        it(@"should allow the user to add objects", ^{
            [store addUserObject:venues[3]];
            __block CMObjectUploadResponse * res = nil;
            [store saveAllUserObjects:^(CMObjectUploadResponse *response) {
                res = response;
            }];
            NSString *objectId1 = [venues[3] objectId];
            
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(res.uploadStatuses) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            [[expectFutureValue(res.uploadStatuses[objectId1]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"created"];
        });
        
        it(@"should allow the user to get the object by class", ^{
            
            __block CMObjectFetchResponse *res = nil;
            [store allUserObjectsOfClass:[Venue class] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
                res = response;
                Venue *fetched = [res.objects lastObject];
                [[fetched should] equal:venues[3]];
            }];
            
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(res.objects) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
        });
        
        it(@"should save all user objects with a save all", ^{
            
            __block NSInteger called = 0;
            __block CMObjectUploadResponse * res = nil;
            [store saveAll:^(CMObjectUploadResponse *response) {
                res = response;
                called++;
            }];
            
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(theValue(called)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@3];
        });

        it(@"should not throw an error when you attempt to save a nil user object", ^{
            [[theBlock(^{
                CMObject *nilObject = nil;
                [store saveUserObject:nilObject callback:^(CMObjectUploadResponse *response) {

                }];
            }) shouldNot] raise];
        });
        
        it(@"should let a user upload a file with a random key", ^{
            NSURL *url = [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"]];
            
            __block CMFileUploadResponse *res = nil;
            [store saveUserFileAtURL:url additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(res.key) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(theValue(res.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMFileCreated)];
        });
        
        it(@"should let a user upload a file with a given key", ^{
            NSURL *url = [NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"]];
            
            __block CMFileUploadResponse *res = nil;
            [store saveUserFileAtURL:url named:@"my_wonderful_key" additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(res.key) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(theValue(res.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMFileCreated)];
        });
        
        it(@"should delete a user file", ^{
            __block CMDeleteResponse *res = nil;
            [store deleteUserFileNamed:@"my_wonderful_key" additionalOptions:nil callback:^(CMDeleteResponse *response) {
                res = response;
            }];
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(res.success) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            [[expectFutureValue(res.success[@"my_wonderful_key"]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"deleted"];
        });
        
        it(@"should fail to save any ACL's when none are passed", ^{
            [[store.webService shouldNot]
             receive:@selector(updateACL:user:successHandler:errorHandler:)];
            
            __block CMObjectUploadResponse *res = nil;
            [store saveACLs:@[] callback:^(CMObjectUploadResponse *response) {
                res = response;
                [[theValue(res.error.code) should] beZero];
                [[res.error should] beNil];
            }];
            
            [[res shouldNot] beNil];
        });

        it(@"should not throw an error when attempting to save a nil ACL", ^{
            [[theBlock(^{
                CMACL *nilACL = nil;
                [store saveACL:nilACL callback:^(CMObjectUploadResponse *response) {

                }];
            }) shouldNot] raise];
        });
        
        it(@"should delete a user object", ^{
            Venue *v = venues[3];
            
            __block CMDeleteResponse *res = nil;
            [store deleteUserObject:v additionalOptions:nil callback:^(CMDeleteResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(res.success) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            [[expectFutureValue(res.success[v.objectId]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"deleted"];
        });
        
        context(@"with ACL's", ^{

            __block CMStore *otherStore = nil;
            __block CMUser *aclUser = nil;
            beforeAll(^{
                CMUser *newUser = [[CMUser alloc] initWithEmail:@"test_acl_user@cloudmine.me" andPassword:@"testing"];
                [newUser createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                    [[theValue(resultCode) should] equal:@(CMUserAccountLoginSucceeded)];
                    aclUser = newUser;
                    otherStore = [CMStore storeWithUser:aclUser];
                }];
                
                [[expectFutureValue(theValue([newUser isLoggedIn])) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beTrue];
                
                ///
                /// Create an object for ACL testing
                ///
                __block CMObjectUploadResponse *res = nil;
                [store saveUserObject:venues[5] callback:^(CMObjectUploadResponse *response) {
                    res = response;
                }];
                
                [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(res.uploadStatuses) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            });
            
            __block NSString *aclID = nil;
            __block CMACL *testACL = nil;
            it(@"should allow the user to add an ACL to an object", ^{
                Venue *v = venues[5];
                
                CMACL *acl = [[CMACL alloc] init];
                acl.permissions = [NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, CMACLDeletePermission, nil];
                acl.members = [NSSet setWithObject:aclUser.objectId];
                aclID = acl.objectId;
                testACL = acl;
                
                __block CMObjectUploadResponse *res = nil;
                [v addACL:acl callback:^(CMObjectUploadResponse *response) {
                    res = response;
                }];
                
                [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(res.error) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
                [[expectFutureValue(res.uploadStatuses[v.objectId]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"updated"];
            });
            
            it(@"should add the ACL when a user fetches the objects", ^{
                CMStoreOptions *options = [[CMStoreOptions alloc] init];
                options.shared = YES;
                
                __block CMObjectFetchResponse *resp = nil;
                [otherStore allUserObjectsOfClass:[Venue class] additionalOptions:options callback:^(CMObjectFetchResponse *response) {
                    resp = response;
                    Venue *v = [response.objects lastObject];
                    [[[v valueForKey:@"sharedACL"] shouldNot] beNil];
                }];
                
                [[expectFutureValue(resp) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(resp.objects) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            });
            
            it(@"should allow the user to search for ACL's", ^{
                NSString *query = [NSString stringWithFormat:@"[objectId=\"%@\"]", aclID];
                
                __block CMACLFetchResponse *res = nil;
                [store searchACLs:query callback:^(CMACLFetchResponse *response) {
                    res = response;
                }];

                [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(res.acls) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
                [[expectFutureValue([res permissionsForMember:aclUser.objectId]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            });
            
            it(@"should delete the ACL", ^{
                __block CMDeleteResponse *res;
                [store deleteACL:testACL callback:^(CMDeleteResponse *response) {
                    res = response;
                }];
                
                [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(res.success) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            });
        });
        

        
        context(@"with a CMUser that is set but not logged in", ^{
            
            beforeEach(^{
                store.user.tokenExpiration = nil;
            });

            it(@"should return a 401 immediately for all user objects", ^{
                [[store.webService shouldNot]
                 receive:@selector(getValuesForKeys:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMObjectFetchResponse *res = nil;
                [store allUserObjectsWithOptions:nil callback:^(CMObjectFetchResponse *response) {
                    res = response;
                }];
                
                [[res shouldNot] beNil];
                
                [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
            });
            
            it(@"should return a 401 immediately for all ACL's", ^{
                __block CMObjectFetchResponse *res = nil;
                [store allUserObjectsWithOptions:nil callback:^(CMObjectFetchResponse *response) {
                    res = response;
                }];

                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
                [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
            });
            
            it(@"should return a 401 immediately for all objects of class", ^{
                [[store.webService shouldNot]
                 receive:@selector(searchValuesFor:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMObjectFetchResponse *res = nil;
                [store allUserObjectsOfClass:[venues class] additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately for searching user objects", ^{
                [[store.webService shouldNot]
                 receive:@selector(searchValuesFor:serverSideFunction:pagingOptions:sortingOptions:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMObjectFetchResponse *res = nil;
                [store searchUserObjects:@"[something=\"okay\"]" additionalOptions:nil callback:^(CMObjectFetchResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately for searching ACL's", ^{
                [[store.webService shouldNot]
                 receive:@selector(searchACLs:user:successHandler:errorHandler:)];
                
                __block CMACLFetchResponse *res = nil;
                [store searchACLs:@"query" callback:^(CMACLFetchResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately for saving all user object's", ^{
                [[store.webService shouldNot]
                 receive:@selector(updateValuesFromDictionary:serverSideFunction:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMObjectUploadResponse *res = nil;
                [store saveAllUserObjects:^(CMObjectUploadResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately for saving a single user object", ^{
                [[store.webService shouldNot]
                 receive:@selector(updateValuesFromDictionary:serverSideFunction:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMObjectUploadResponse *res = nil;
                [store saveUserObject:[CMObject new] callback:^(CMObjectUploadResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when saving an ACL", ^{
                [[store.webService shouldNot]
                 receive:@selector(updateACL:user:successHandler:errorHandler:)];
                
                __block CMObjectUploadResponse *res = nil;
                [store saveACLs:@[[[CMACL alloc] init]] callback:^(CMObjectUploadResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when saving a file from a URL", ^{
                [[store.webService shouldNot]
                 receive:@selector(uploadFileAtPath:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMFileUploadResponse *res = nil;
                [store saveUserFileAtURL:nil additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when saving a file from a URL with a name", ^{
                [[store.webService shouldNot]
                 receive:@selector(uploadFileAtPath:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMFileUploadResponse *res = nil;
                [store saveUserFileAtURL:nil named:@"something" additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when saving a file from data", ^{
                [[store.webService shouldNot]
                 receive:@selector(uploadBinaryData:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMFileUploadResponse *res = nil;
                [store saveUserFileWithData:[NSData new] additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when saving a file from data and a name", ^{
                [[store.webService shouldNot]
                 receive:@selector(uploadBinaryData:serverSideFunction:named:ofMimeType:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMFileUploadResponse *res = nil;
                [store saveUserFileWithData:[NSData new] named:@"name" additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when fetching a file", ^{
                [[store.webService shouldNot]
                 receive:@selector(getBinaryDataNamed:serverSideFunction:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMFileFetchResponse *res = nil;
                [store userFileWithName:@"something" additionalOptions:nil callback:^(CMFileFetchResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when deleting a user object", ^{
                [[store.webService shouldNot]
                 receive:@selector(deleteValuesForKeys:serverSideFunction:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMDeleteResponse *res = nil;
                [store deleteUserObject:[CMObject new] additionalOptions:nil callback:^(CMDeleteResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when deleting many user objects", ^{
                [[store.webService shouldNot]
                 receive:@selector(deleteValuesForKeys:serverSideFunction:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMDeleteResponse *res = nil;
                [store deleteUserObjects:@[] additionalOptions:nil callback:^(CMDeleteResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when deleting a user file", ^{
                [[store.webService shouldNot]
                 receive:@selector(deleteValuesForKeys:serverSideFunction:user:extraParameters:successHandler:errorHandler:)];
                
                __block CMDeleteResponse *res = nil;
                [store deleteUserFileNamed:@"name" additionalOptions:nil callback:^(CMDeleteResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });
            
            it(@"should return a 401 immediately when deleting an ACL", ^{
                [[store.webService shouldNot]
                 receive:@selector(deleteACLWithKey:user:successHandler:errorHandler:)];
                
                __block CMDeleteResponse *res = nil;
                [store deleteACLs:@[[CMACL new]] callback:^(CMDeleteResponse *response) {
                    res = response;
                    [[theValue(res.error.code) should] equal:@(CMErrorUnauthorized)];
                    [[res.error.domain should] equal:CMErrorDomain];
                }];
                
                [[res shouldNot] beNil];
                [[res.error should] beNonNil];
            });




        });
    });

    
});

SPEC_END
