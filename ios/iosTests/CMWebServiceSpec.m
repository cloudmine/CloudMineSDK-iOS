//
//  CMWebServiceSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#import "CMBlockValidationMessageSpy.h"
#import "CMWebService.h"

SPEC_BEGIN(CMWebServiceSpec)

describe(@"CMWebService", ^{
    __block NSString *appId = @"appId123";
    __block NSString *appSecret = @"appSecret123";
    __block CMWebService *service = nil;
    
    beforeEach(^{
        service = [[CMWebService alloc] initWithAPIKey:appSecret appKey:appId];
        service.networkQueue = [ASINetworkQueue mock];
    });
    
    it(@"should construct app-level GET request URLs correctly", ^{
//        NSString *expectedUrl = [NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId];
        
        id spy = [[CMBlockValidationMessageSpy alloc] init];
        [spy addValidationBlock:^(NSInvocation *invocation) {
            NSLog(@"Received invocation (%@)", invocation);
        } forSelector:@selector(addOperation:)];
        
        [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
        
        [[service.networkQueue should] receive:@selector(addOperation:)];
        [[service.networkQueue should] receive:@selector(go)];
        
        [service getValuesForKeys:[NSArray arrayWithObjects:@"key1",@"key2", nil]
                   successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       NSLog(@"success");
                   } errorHandler:^(NSError *error) {
                       NSLog(@"error");
                   }];    
    });
});

SPEC_END
