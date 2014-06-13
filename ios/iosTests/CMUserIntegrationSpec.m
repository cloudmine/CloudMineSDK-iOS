//
//  CMUserIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/23/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMAPICredentials.h"
#import "CMUser.h"
#import "CMCardPayment.h"
#import "CMWebService.h"

SPEC_BEGIN(CMUserIntegrationSpec)

///
/// If this assertion fails, command click the macro, and change the default to 2.0
///
assert(kKW_DEFAULT_PROBE_TIMEOUT == 2.0);

describe(@"CMUser Integration", ^{
    
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"9977f87e6ae54815b32a663902c3ca65"];
        [[CMAPICredentials sharedInstance] setAppSecret:@"c701d73554594315948c8d3cc0711ac1"];
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
            
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountCreateSucceeded)];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
        });
        
        it(@"should successfully login them in", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountLoginSucceeded)];
            [[expectFutureValue(user.token) shouldEventually] beNonNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventually] beNonNil];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
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
            
            [[expectFutureValue(theValue(code)) shouldEventually] equal:@(CMUserAccountLogoutSucceeded)];
            [[expectFutureValue(user.token) shouldEventually] beNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventually] beNil];
        });
        
        it(@"should fail to login when creating a bad account", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test" andPassword:@"testing"];
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [user createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
                NSLog(@"WHAT: %@", messages);
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventually] equal:@(CMUserAccountCreateFailedInvalidRequest)];
            [[expectFutureValue(user.token) shouldEventually] beNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventually] beNil];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
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
            
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountLoginSucceeded)];
            [[expectFutureValue(user.token) shouldEventually] beNonNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventually] beNonNil];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
        });
        
        it(@"should change the password", ^{
            
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [testUser changePasswordTo:@"newPassword" from:@"testing" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountPasswordChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
            [[expectFutureValue(testUser.token) shouldEventually] beNonNil];
            [[expectFutureValue(testUser.tokenExpiration) shouldEventually] beNonNil];
        });
        
        it(@"should change the email", ^{
#warning This is actually broken due to a bug (I think) in the platform
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [testUser changeEmailTo:@"test_new_email@test.com" password:@"newPassword" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountEmailChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
            [[expectFutureValue(testUser.token) shouldEventually] beNonNil];
            [[expectFutureValue(testUser.tokenExpiration) shouldEventually] beNonNil];
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
                NSLog(@"Message: %@", messages);
            }];
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountUsernameChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
            [[expectFutureValue(testUser.token) shouldEventually] beNonNil];
            [[expectFutureValue(testUser.tokenExpiration) shouldEventually] beNonNil];
        });
        
        it(@"should change the userId, which is really the email", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [testUser changeUserIdTo:@"test_userid_change@test.com" password:@"newPassword" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountUserIdChangeSucceeded)];
#pragma clang diagnostic pop
            [[expectFutureValue(mes) shouldEventually] beEmpty];
        });
        
        it(@"should change the username, email, and password", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            [testUser changeUserCredentialsWithPassword:@"newPassword"
                                            newPassword:@"newestPassword"
                                            newUsername:@"MyUsername"
                                               newEmail:@"coolEmail@test.com"
                                               callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                                                   code = resultCode;
                                                   mes = messages;
                                               }];
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountCredentialChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
        });
        
        it(@"should change the username, userid (email) and password", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;

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
            [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountCredentialChangeSucceeded)];
            [[expectFutureValue(mes) shouldEventually] beEmpty];
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
                
                [[expectFutureValue(theValue(code)) shouldEventually] equal:theValue(CMUserAccountLoginSucceeded)];
                [[expectFutureValue(mes) shouldEventually] beEmpty];
            });
            
            it(@"should add a card", ^{
                __block CMPaymentResponse *res = nil;
                [cardUser addPaymentMethod:card callback:^(CMPaymentResponse *response) {
                    res = response;
                }];
                
                [[expectFutureValue(res) shouldEventually] beNonNil];
                [[expectFutureValue(@(res.result)) shouldEventually] equal:@(CMPaymentResultSuccessful)];
                [[expectFutureValue(@(res.httpResponseCode)) shouldEventually] equal:@(200)];
                [[expectFutureValue(res.errors) shouldEventually] beEmpty];
                [[expectFutureValue(res.body[@"added"]) shouldEventually] equal:@(0)];
            });
            
            it(@"should fetch the payment methods", ^{
                __block CMPaymentResponse *res = nil;
                [cardUser paymentMethods:^(CMPaymentResponse *response) {
                    res = response;
                }];
                [[expectFutureValue(res) shouldEventually] beNonNil];
                [[expectFutureValue(@(res.result)) shouldEventually] equal:@(CMPaymentResultSuccessful)];
                [[expectFutureValue(@(res.httpResponseCode)) shouldEventually] equal:@(200)];
                [[expectFutureValue(res.errors) shouldEventually] beEmpty];
                [[expectFutureValue(res.body) shouldEventually] haveCountOf:1];
                
                [[expectFutureValue(((CMCardPayment *)res.body[0]).token) shouldEventually] equal:@"3243249390328409"];
            });
            
            it(@"should let you remove a payment method", ^{
                __block CMPaymentResponse *res = nil;
                [cardUser removePaymentMethodAtIndex:0 callback:^(CMPaymentResponse *response) {
                    res = response;
                }];
                [[expectFutureValue(res) shouldEventually] beNonNil];
                [[expectFutureValue(@(res.result)) shouldEventually] equal:@(CMPaymentResultSuccessful)];
                [[expectFutureValue(@([res wasSuccess])) shouldEventually] equal:@(YES)];
                [[expectFutureValue(res.errors) shouldEventually] beEmpty];
                [[expectFutureValue(res.body) shouldEventually] haveCountOf:1];
            });
            
            it(@"fetching payment methods again should return nothing", ^{
                __block CMPaymentResponse *res = nil;
                [cardUser paymentMethods:^(CMPaymentResponse *response) {
                    res = response;
                }];
                [[expectFutureValue(res) shouldEventually] beNonNil];
                [[expectFutureValue(@(res.result)) shouldEventually] equal:@(CMPaymentResultSuccessful)];
                [[expectFutureValue(@(res.httpResponseCode)) shouldEventually] equal:@(200)];
                [[expectFutureValue(res.errors) shouldEventually] beEmpty];
                [[expectFutureValue(res.body) shouldEventually] haveCountOf:0];
            });
            
        });
    });
    
    context(@"searching for users", ^{
        
        it(@"should find all users", ^{
            __block NSArray *all = nil;
            __block NSDictionary *error = nil;
            
            [CMUser allUsersWithCallback:^(NSArray *users, NSDictionary *errors) {
                all = users;
                error = errors;
            }];
            
            [[expectFutureValue(all) shouldEventually] beNonNil];
            [[expectFutureValue(all) shouldEventually] haveCountOf:4];
            [[expectFutureValue(error) shouldEventually] beEmpty];
        });
        
        __block NSString *identifier = nil;
        it(@"should search for a particular user", ^{
            __block NSArray *all = nil;
            __block NSDictionary *error = nil;
            
            [CMUser searchUsers:@"[email=\"testcard@cloudmine.me\"]" callback:^(NSArray *users, NSDictionary *errors) {
                all = users;
                error = errors;
                CMUser *found = all[0];
                identifier = found.objectId;
            }];
            
            [[expectFutureValue(all) shouldEventually] beNonNil];
            [[expectFutureValue(all) shouldEventually] haveCountOf:1];
            [[expectFutureValue(error) shouldEventually] beEmpty];
            CMUser *found = all[0];
            [[expectFutureValue(found.email) shouldEventually] equal:@"testcard@cloudmine.me"];
        });
        
        it(@"should get a cached user once we have gotten them all", ^{
            
            __block NSArray *all = nil;
            __block NSDictionary *error = nil;
            
            [[identifier should] beNonNil];
            [CMUser userWithIdentifier:identifier callback:^(NSArray *users, NSDictionary *errors) {
                all = users;
                error = errors;
            }];
            
            [[expectFutureValue(all) shouldEventually] beNonNil];
            [[expectFutureValue(all) shouldEventually] haveCountOf:1];
            [[expectFutureValue(error) shouldEventually] beEmpty];
            CMUser *found = all[0];
            [[expectFutureValue(found.email) shouldEventually] equal:@"testcard@cloudmine.me"];
            [[[CMWebService sharedWebService] shouldNotEventually] receive:@selector(getUserProfileWithIdentifier:callback:)];
        });
       
        
    });
    
});

SPEC_END