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
#import "CMUserCredentials.h"

SPEC_BEGIN(CMWebServiceSpec)

describe(@"CMWebService", ^{
    __block NSString *appId = @"appId123";
    __block NSString *appSecret = @"appSecret123";
    __block CMWebService *service = nil;
    
    beforeEach(^{
        service = [[CMWebService alloc] initWithAPIKey:appSecret appKey:appId];
        service.networkQueue = [ASINetworkQueue mock];
    });
    
    context(@"should construct GET request", ^{
        it(@"URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"URLs at the app level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1,k2", appId]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:nil
                  withUserCredentials:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text?keys=k1,k2", appId]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service getValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                  withUserCredentials:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        }); 
    });
    
    context(@"should construct POST request", ^{
        it(@"URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"POST"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request.postBody yajl_JSON] should] equal:dataToPost];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service updateValuesFromDictionary:dataToPost 
                                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];    
        });
        
        it(@"URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"POST"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request.postBody yajl_JSON] should] equal:dataToPost];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service updateValuesFromDictionary:dataToPost
                            withUserCredentials:creds
                                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];    
        });
    });
    
    context(@"should construct PUT request", ^{
        it(@"URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"PUT"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request.postBody yajl_JSON] should] equal:dataToPost];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service setValuesFromDictionary:dataToPost 
                                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];    
        });
        
        it(@"URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"PUT"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request.postBody yajl_JSON] should] equal:dataToPost];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service setValuesFromDictionary:dataToPost
                            withUserCredentials:creds
                                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];    
        });
    });
    
    context(@"should construct DELETE request", ^{
        it(@"URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data", appId]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"DELETE"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service deleteValuesForKeys:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"URLs at the app level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data?keys=k1,k2", appId]];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"DELETE"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service deleteValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data", appId]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"DELETE"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service deleteValuesForKeys:nil
                  withUserCredentials:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        });
        
        it(@"URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data?keys=k1,k2", appId]];
            CMUserCredentials *creds = [[CMUserCredentials alloc] initWithUserId:@"user" andPassword:@"pass"];
            
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.username should] equal:@"user"];
                [[request.password should] equal:@"pass"];
                [[request.requestMethod should] equal:@"DELETE"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];
            
            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];
            
            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];
            
            [service deleteValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                  withUserCredentials:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors) {
                       } errorHandler:^(NSError *error) {
                       }
             ];    
        }); 
    });

});

SPEC_END

