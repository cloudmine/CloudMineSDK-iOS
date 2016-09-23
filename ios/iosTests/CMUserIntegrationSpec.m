//
//  CMUserIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/23/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMAPICredentials.h"
#import "CMUser.h"
#import "CMCardPayment.h"
#import "CMWebService.h"
#import "CMConstants.h"
#import "TestUser.h"
#import "CMUserResponse.h"
#import "CMTestMacros.h"

SPEC_BEGIN(CMUserIntegrationSpec)

describe(@"CMUser Integration", ^{
    
    beforeAll(^{

        [[CMAPICredentials sharedInstance] setAppIdentifier:APP_ID];
        [[CMAPICredentials sharedInstance] setApiKey:API_KEY];
        [[CMAPICredentials sharedInstance] setBaseURL:BASE_URL];
        
        __block CMUserAccountResult code = NSNotFound;
        [[CMUser currentUser] logoutWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
            code = resultCode;
        }];
        [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountLogoutSucceeded)];
    });
    
    context(@"given a real user", ^{
        
        it(@"it should successfully create the user on the server", ^{
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            
            [user createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountCreateSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should create an account with a username", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            CMUser *user = [[CMUser alloc] initWithUsername:@"MyGreatName" andPassword:@"testing"];
            [user createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountCreateSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should fail to create an account with the same username", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            CMUser *user = [[CMUser alloc] initWithUsername:@"MyGreatName" andPassword:@"testing"];
            [user createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountCreateFailedDuplicateAccount)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should successfully login them in", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountLoginSucceeded)];
            [[expectFutureValue(user.token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should successfully logout", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                [[theValue(resultCode) should] equal:@(CMUserAccountLoginSucceeded)];
                [[user.token should] beNonNil];
                [[user.tokenExpiration should] beNonNil];
                
                [user logoutWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                    code = resultCode;
                    mes = messages;
                }];
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMUserAccountLogoutSucceeded)];
            [[expectFutureValue(user.token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
        });
        
        it(@"should fail to login when creating a bad account", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test" andPassword:@"testing"];
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMUserAccountCreateFailedInvalidRequest)];
            [[expectFutureValue(user.token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should fail to login with the wrong credentials", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testingbad"];
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountLoginFailedIncorrectCredentials)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should fail to save the user when they are not logged in", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:nil];
            [user setValue:@"random" forKey:@"objectId"];
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user save:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[theValue(code) should] equal:theValue(CMUserAccountLoginFailedIncorrectCredentials)];
            [[mes should] beEmpty];
        });
        
        it(@"should attempt to login them in on a save", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"wrongpassword"];
            [user setValue:@"random" forKey:@"objectId"];
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user save:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountLoginFailedIncorrectCredentials)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should create the user on a save if they haven't been created", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test_save_remote@cloudmine.me" andPassword:@"testing"];

            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user save:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountCreateSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        __block CMUser *testUser = nil;
        it(@"should successfully login them in again", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
                testUser = user;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountLoginSucceeded)];
            [[expectFutureValue(user.token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should login the user if they have the correct username set", ^{
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;

            [testUser logoutWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                testUser.password = @"testing";
                [testUser save:^(CMUserAccountResult resultCode, NSArray *messages) {
                    code = resultCode;
                    mes = messages;
                }];
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountProfileUpdateSucceeded)];
            [[expectFutureValue(testUser.token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(testUser.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should let the user save", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            [testUser save:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountProfileUpdateSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should fetch the user's profile", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            [testUser getProfile:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountProfileUpdateSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveLengthOf:1];
        });
        
        it(@"should change the password", ^{
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [testUser changePasswordTo:@"newPassword" from:@"testing" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountPasswordChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            [[expectFutureValue(testUser.token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(testUser.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        });
        
        it(@"should change the email", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [testUser changeEmailTo:@"test_new_email@test.com" password:@"newPassword" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountEmailChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            [[expectFutureValue(testUser.token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(testUser.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(testUser.email) should] equal:@"test_new_email@test.com"];
        });
        
        it(@"should change the username", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            [[@(testUser.isLoggedIn) should] equal:@YES];
            [[testUser.email should] equal:@"test_new_email@test.com"];
            
            [testUser changeUsernameTo:@"NewUsername" password:@"newPassword" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountUsernameChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            [[expectFutureValue(testUser.token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(testUser.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(testUser.username) should] equal:@"NewUsername"];
        });
        
        it(@"should change the userId, which is really the email", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            ///
            /// Force setting them to be correct
            ///
            testUser.email = @"test_new_email@test.com";
            testUser.password = @"newPassword";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [testUser changeUserIdTo:@"test_userid_change@test.com" password:@"newPassword" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountEmailChangeSucceeded)];
#pragma clang diagnostic pop
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should change the username, email, and password", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            testUser.email = @"test_userid_change@test.com";
            testUser.password = @"newPassword";
            [testUser changeUserCredentialsWithPassword:@"newPassword"
                                            newPassword:@"newestPassword"
                                            newUsername:@"MyUsername"
                                               newEmail:@"coolEmail@test.com"
                                               callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                                                   code = resultCode;
                                                   mes = messages;
                                               }];
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountCredentialChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should change the username, userid (email) and password", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            testUser.email = @"coolEmail@test.com";
            testUser.password = @"newestPassword";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [testUser changeUserCredentialsWithPassword:@"newestPassword"
                                            newPassword:@"thisiscrazy"
                                            newUsername:@"HowManyToDo"
                                              newUserId:@"thisisemail@test.com"
                                               callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                                                   code = resultCode;
                                                   mes = messages;
                                               }];
#pragma clang diagnostic pop
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountCredentialChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            [[expectFutureValue(testUser.email) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"thisisemail@test.com"];
            [[expectFutureValue(testUser.username) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"HowManyToDo"];

        });
        
        
        context(@"given a CMUser subclass", ^{
            
            __block TestUser *testSubclassUser = nil;
            beforeAll(^{
                __block CMUserAccountResult code = NSNotFound;
                __block NSArray *mes = nil;
                
                testSubclassUser = [[TestUser alloc] initWithEmail:@"testsubclassuser@cloudmine.me" andPassword:@"testing"];
                testSubclassUser.firstName = @"Ethan";
                testSubclassUser.lastName = @"Mick";
                
                [testSubclassUser createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                    code = resultCode;
                    mes = messages;
                }];
                
                [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountLoginSucceeded)];
                [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            });
            
            it(@"should fetch the user's profile", ^{
                __block CMUserAccountResult code = NSNotFound;
                __block NSArray *mes = nil;
                
                [testSubclassUser getProfile:^(CMUserAccountResult resultCode, NSArray *messages) {
                    code = resultCode;
                    mes = messages;
                    [[mes[0][@"firstName"] should] equal:@"Ethan"];
                    [[mes[0][@"lastName"] should] equal:@"Mick"];
                }];
                
                [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountProfileUpdateSucceeded)];
                [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveLengthOf:1];
            });
        });
        
        context(@"given some payment info", ^{
            
            __block CMUser *cardUser = nil;
            __block CMCardPayment *card = nil;
            __block NSString *cardId = nil;
            beforeAll(^{
                card = [[CMCardPayment alloc] init];
                card.nameOnCard = @"Ethan Smith";
                card.token = @"3243249390328409";
                card.expirationDate = @"0916";
                card.last4Digits = @"1111";
                card.type = CMCardPaymentTypeVisa;
                cardId = card.objectId;
                
                __block CMUserAccountResult code = NSNotFound;
                __block NSArray *mes = nil;
                
                CMUser *user = [[CMUser alloc] initWithEmail:@"testcard@cloudmine.me" andPassword:@"testing"];
                
                [user createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                    code = resultCode;
                    mes = messages;
                    cardUser = user;
                }];
                
                [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountLoginSucceeded)];
                [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            });
            
            it(@"should add a card", ^{
                __block CMPaymentResponse *res = nil;
                [cardUser addPaymentMethod:card callback:^(CMPaymentResponse *response) {
                    res = response;
                }];
                
                [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(@(res.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMPaymentResultSuccessful)];
                [[expectFutureValue(@(res.httpResponseCode)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(200)];
                [[expectFutureValue(res.errors) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
                [[expectFutureValue(res.body[@"added"]) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(0)];
            });
            
            it(@"should fetch the payment methods", ^{
                __block CMPaymentResponse *res = nil;
                [cardUser paymentMethods:^(CMPaymentResponse *response) {
                    res = response;
                }];
                [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(@(res.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMPaymentResultSuccessful)];
                [[expectFutureValue(@(res.httpResponseCode)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(200)];
                [[expectFutureValue(res.errors) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
                [[expectFutureValue(res.body) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
                
                [[expectFutureValue(((CMCardPayment *)res.body[0]).token) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"3243249390328409"];
            });
            
            it(@"should let you remove a payment method", ^{
                __block CMPaymentResponse *res = nil;
                [cardUser removePaymentMethodAtIndex:0 callback:^(CMPaymentResponse *response) {
                    res = response;
                }];
                [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(@(res.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMPaymentResultSuccessful)];
                [[expectFutureValue(@([res wasSuccess])) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(YES)];
                [[expectFutureValue(res.errors) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
                [[expectFutureValue(res.body) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            });
            
            it(@"fetching payment methods again should return nothing", ^{
                __block CMPaymentResponse *res = nil;
                [cardUser paymentMethods:^(CMPaymentResponse *response) {
                    res = response;
                }];
                [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
                [[expectFutureValue(@(res.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(CMPaymentResultSuccessful)];
                [[expectFutureValue(@(res.httpResponseCode)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@(200)];
                [[expectFutureValue(res.errors) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
                [[expectFutureValue(res.body) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:0];
            });
            
        });
    });
    
    context(@"searching for users", ^{
        
        beforeAll(^{
            [[CMWebService sharedWebService] setValue:@"9977f87e6ae54815b32a663902c3ca65" forKey:@"_appIdentifier"];
            [[CMWebService sharedWebService] setValue:@"c701d73554594315948c8d3cc0711ac1" forKey:@"_appSecret"];
            [[CMWebService sharedWebService] setValue:CM_BASE_URL forKey:@"apiUrl"];
        });
        
        it(@"should find all users", ^{
            __block NSArray *all = nil;
            __block NSDictionary *error = nil;
            
            [CMUser allUsersWithCallback:^(NSArray *users, NSDictionary *errors) {
                all = users;
                error = errors;
            }];
            
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:10];
            [[expectFutureValue(error) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should find all users when given no query or identifier", ^{
            
            __block NSArray *all = nil;
            __block NSError *error = nil;
            
            [CMUser allUserWithOptions:nil callback:^(CMObjectFetchResponse *response) {
                all = response.objects;
                error = response.error;
            }];
            
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:10];
            [[expectFutureValue(error) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
        });
        
        it(@"should return the count of users", ^{
            __block NSArray *all = nil;
            __block NSError *error = nil;
            
            CMPagingDescriptor *paging = [[CMPagingDescriptor alloc] initWithLimit:5 skip:0 includeCount:YES];
            CMStoreOptions *options = [[CMStoreOptions alloc] initWithPagingDescriptor:paging];
            
            [CMUser allUserWithOptions:options callback:^(CMObjectFetchResponse *response) {
                all = response.objects;
                error = response.error;
                [[theValue(response.count) should] equal:theValue(10)];
            }];
            
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:5];
            [[expectFutureValue(error) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
        });
        
        __block NSString *identifier = nil;
        it(@"should search for a particular user", ^{
            __block NSArray *all = nil;
            __block NSDictionary *error = nil;
            
            [CMUser searchUsers:@"[email=\"testcard@cloudmine.me\"]" callback:^(NSArray *users, NSDictionary *errors) {
                all = users;
                error = errors;
                [[all should] haveCountOf:1];
                if (all.count > 0) {
                    CMUser *found = all[0];
                    identifier = found.objectId;
                }
            }];
            
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            [[expectFutureValue(error) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            [[expectFutureValue(((CMUser *)all[0]).email) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"testcard@cloudmine.me"];
        });
        
        identifier = nil;
        it(@"should search for a particular user using the new meta", ^{
            __block NSArray *all = nil;
            __block NSError *error = nil;
            
            [CMUser searchUsers:@"[email=\"testcard@cloudmine.me\"]" options:nil callback:^(CMObjectFetchResponse *response) {
                all = response.objects;
                error = response.error;
                [[all should] haveCountOf:1];
                if (all.count > 0) {
                    CMUser *found = all[0];
                    identifier = found.objectId;
                }
            }];

            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            [[expectFutureValue(error) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
            [[expectFutureValue(((CMUser *)all[0]).email) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:@"testcard@cloudmine.me"];
        });

        
        it(@"should get a cached user once we have gotten them all", ^{
            
            __block NSArray *all = nil;
            __block NSDictionary *error = nil;
            
            [[identifier should] beNonNil];
            [CMUser userWithIdentifier:identifier callback:^(NSArray *users, NSDictionary *errors) {
                all = users;
                error = errors;
                if (all.count > 0) {
                    CMUser *found = all[0];
                    [[found.email should] equal:@"testcard@cloudmine.me"];
                } else {
                    fail(@"Fail!");
                }
            }];
            
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
            [[expectFutureValue(all) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] haveCountOf:1];
            [[expectFutureValue(error) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            [[[CMWebService sharedWebService] shouldNotEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] receive:@selector(getUserProfileWithIdentifier:callback:)];
        });
    });
    
    context(@"with a wrong appid", ^{
        beforeAll(^{
            [[CMAPICredentials sharedInstance] setAppIdentifier:@"9977f87e6ae99915b32a663902c3ca65"];
            [[CMAPICredentials sharedInstance] setApiKey:@"c701d73554594315948c8d3cc0711ac1"];
        });

        it(@"should fail to login a user", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountOperationFailedUnknownAccount)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should fail to logout the user", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000];
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user logoutWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMUserAccountOperationFailedUnknownAccount)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
        });
        
        it(@"should fail to fetch the profile", ^{
            [[CMWebService sharedWebService] setValue:@"9988f87e6ae54815b32a663902c3ca65" forKey:@"_appIdentifier"];
            __block NSArray *use = [NSArray arrayWithObject:[NSObject new]];
            __block NSDictionary *err = [NSDictionary dictionary];
            [CMUser allUsersWithCallback:^(NSArray *users, NSDictionary *errors) {
                use = users;
                err = errors;
            }];
            
            [[expectFutureValue(use) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beEmpty];
            [[expectFutureValue(err) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNil];
        });
    });

    context(@"given a native social CMUser", ^{
        
        //
        // This is specific to CMSocial, and so we need to reset our appid and secret. This can
        // be removed when we are in production for everyone.
        //
        beforeAll(^{
            [[CMAPICredentials sharedInstance] setAppIdentifier:@"028f6a795835448ea80b8ed38cf98b50"];
            [[CMAPICredentials sharedInstance] setApiKey:@"6d6f5ca1a2e74832881a3d2f369ea653"];
        });
        
        __block CMUser *user = nil;
        it(@"should create a facebook user", ^{
            NSDictionary *env = [[NSProcessInfo processInfo] environment];
            
            NSString *token = env[@"FacebookToken"];
            
            if (token.length == 0) {
                return;
            }
            
            __block CMUserResponse *res = nil;
            [CMUser userWithSocialNetwork:CMSocialNetworkFacebook
                              accessToken:token
                              descriptors:nil
                                 callback:^(CMUserResponse *response) {
                                     res = response;
                                     [[theValue(response.result) should] equal:theValue(CMUserAccountLoginSucceeded)];
                                     [[response.user should] beNonNil];
                                     user = response.user;
                                     [[theValue(response.user.isLoggedIn) should] beYes];
                                 }];
            
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        });
        
        it(@"should let the user add another social account natively", ^{
            ///
            /// If this is broken, you should go to https://apps.twitter.com/app
            /// and regenerate the access tokens for the app you want to install
            ///
            NSDictionary *env = [[NSProcessInfo processInfo] environment];
            
            NSString *token = env[@"TwitterToken"];
            NSString *secret = env[@"TwitterSecret"];
            
            if (token.length == 0 && secret.length == 0) {
                return;
            }
            
            __block CMUserResponse *res = nil;
            [user loginWithSocialNetwork:CMSocialNetworkTwitter
                               oauthToken:token
                         oauthTokenSecret:secret
                             descriptors:nil
                                 callback:^(CMUserResponse *response) {
                                     res = response;
                                     [[theValue(response.result) should] equal:theValue(CMUserAccountLoginSucceeded)];
                                     [[response.user should] beNonNil];
                                     [[response.user.services should] haveCountOfAtLeast:2];
                                     [[theValue(response.user.isLoggedIn) should] beYes];
                                 }];
            
            [[expectFutureValue(res) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        });
        
    });
    
});

SPEC_END
