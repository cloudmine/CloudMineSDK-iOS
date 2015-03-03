//
//  CMACLIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/5/14.
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMAPICredentials.h"
#import "CMTestMacros.h"

SPEC_BEGIN(CMACLIntegrationSpec)

describe(@"CMACL Integration", ^{
    
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:APP_ID];
        [[CMAPICredentials sharedInstance] setAppSecret:API_KEY];
        [[CMAPICredentials sharedInstance] setBaseURL:BASE_URL];
    });
    
    context(@"given an ACL", ^{
        it(@"it should save properly", ^{
            
        });
    });
});

SPEC_END