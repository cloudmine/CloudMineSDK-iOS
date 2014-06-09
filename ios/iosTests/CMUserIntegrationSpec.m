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

SPEC_BEGIN(CMUserIntegrationSpec)

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
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:theValue(CMUserAccountCreateSucceeded)];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(2.0)] beEmpty];
        });
        
        it(@"should successfully login them in", ^{
            __block CMUserAccountResult code = NSNotFound;
            __block NSArray *mes = nil;
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
                mes = messages;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:theValue(CMUserAccountLoginSucceeded)];
            [[expectFutureValue(user.token) shouldEventuallyBeforeTimingOutAfter(2.0)] beNonNil];
            [[expectFutureValue(user.tokenExpiration) shouldEventuallyBeforeTimingOutAfter(2.0)] beNonNil];
            [[expectFutureValue(mes) shouldEventuallyBeforeTimingOutAfter(2.0)] beEmpty];
        });
    });
});

SPEC_END