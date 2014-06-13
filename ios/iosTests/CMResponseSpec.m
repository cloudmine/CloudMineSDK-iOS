//
//  CMResponseSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMResponse.h"
#import "CMViewChannelsResponse.h"

SPEC_BEGIN(CMResponseSpec)

describe(@"CMResponse", ^{
    
    it(@"should properly be created", ^{
        CMResponse *response = [[CMResponse alloc] initWithResponseBody:@{} httpCode:200 error:nil];
        [[@(response.httpResponseCode) should] equal:@200];
        [[response.errors should] beEmpty];
        [[response.body should] beEmpty];
    });
    
    it(@"should have a good description", ^{
        CMResponse *response = [[CMResponse alloc] initWithResponseBody:@{} httpCode:200 error:nil];
        NSString *desc = [response description];
        [[ theValue([desc rangeOfString:@"CMResponse"].location) shouldNot] equal:@(NSNotFound)];
        [[ theValue([desc rangeOfString:@"HTTP Code:"].location) shouldNot] equal:@(NSNotFound)];
    });
    
    it(@"should know if it was successful", ^{
        CMResponse *response = [[CMResponse alloc] initWithResponseBody:@{} httpCode:200 error:nil];
        [[@([response wasSuccess]) should] beTrue];
        
        CMResponse *response2 = [[CMResponse alloc] initWithResponseBody:@{} httpCode:201 error:nil];
        [[@([response2 wasSuccess]) should] beTrue];
        
        CMResponse *response3 = [[CMResponse alloc] initWithResponseBody:@{} httpCode:299 error:nil];
        [[@([response3 wasSuccess]) should] beTrue];
        
        CMResponse *response4 = [[CMResponse alloc] initWithResponseBody:@{} httpCode:300 error:nil];
        [[@([response4 wasSuccess]) should] beFalse];
    });
    
    
    context(@"CMViewChannelResponse", ^{
        
        it(@"should return a success enum", ^{
            CMViewChannelsResponse *response = [[CMViewChannelsResponse alloc] initWithResponseBody:@[] httpCode:200 error:nil];
            [[theValue(response.result) should] equal:@(CMViewChannelsRequestSucceeded)];
        });
        
        it(@"should return a failure enum", ^{
            CMViewChannelsResponse *response = [[CMViewChannelsResponse alloc] initWithResponseBody:@[] httpCode:400 error:nil];
            [[theValue(response.result) should] equal:@(CMViewChannelsRequestFailed)];
        });
        
        it(@"should return the body", ^{
            CMViewChannelsResponse *response = [[CMViewChannelsResponse alloc] initWithResponseBody:@[] httpCode:400 error:nil];
            [[response.channels should] beEmpty];
        });
        
    });
});

SPEC_END
