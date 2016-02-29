//
//  CMAPICredentialsSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//


#import "Kiwi.h"
#import "CMAPICredentials.h"

SPEC_BEGIN(CMAPICredentialsSpec)

describe(@"CMAPICredentials", ^{
    
    it(@"should be a singleton", ^{
        [[[CMAPICredentials sharedInstance] should] equal:[CMAPICredentials sharedInstance]];
    });
    
});

SPEC_END
