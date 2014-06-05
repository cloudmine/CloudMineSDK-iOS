//
//  CMACLIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/5/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMAPICredentials.h"

SPEC_BEGIN(CMUserIntegrationSpec)

describe(@"CMACL Integration", ^{
    
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"9977f87e6ae54815b32a663902c3ca65"];
        [[CMAPICredentials sharedInstance] setAppSecret:@"c701d73554594315948c8d3cc0711ac1"];
    });
    
    context(@"given an ACL", ^{
        it(@"it should save properly", ^{
            
        });
    });
});

SPEC_END