//
//  CMWebServiceIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMWebService.h"
#import "CMAPICredentials.h"

SPEC_BEGIN(CMWebServiceIntegrationSpec)

describe(@"CMWebServiceIntegration", ^{
    
    __block CMWebService *service = nil;
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"9977f87e6ae54815b32a663902c3ca65"];
        [[CMAPICredentials sharedInstance] setAppSecret:@"c701d73554594315948c8d3cc0711ac1"];
        
        service = [[CMWebService alloc] init];
        
    });
    
    
    context(@"push notifications", ^{
        
        it(@"should get the push channels", ^{
            
            __block CMViewChannelsResponse *res = nil;
            [service getChannelsForThisDeviceWithCallback:^(CMViewChannelsResponse *response) {
                res = response;
            }];
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMViewChannelsRequestSucceeded)];
        });
        
        it(@"should subscribe the device to channel", ^{
            __block CMChannelResponse *res = nil;
            // No way to create channels without REST API
            [service subscribeThisDeviceToPushChannel:@"channel" callback:^(CMChannelResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMDeviceChannelOperationFailed)];
        });
        
    });
    
});

SPEC_END
