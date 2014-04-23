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
            
            __block CMUserAccountResult code = -1;
            __block NSArray *mes = nil;
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@test.com" andPassword:@"testing"];
            
            [user createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                NSLog(@"FINISHED ASYNC:");
                code = resultCode;
                mes = messages;
            }];
            
            [[theValue(code) shouldEventuallyBeforeTimingOutAfter(5.0)] equal:theValue(2)];
            [[mes shouldEventuallyBeforeTimingOutAfter(5.0)] beEmpty];
        });
    });
});

SPEC_END