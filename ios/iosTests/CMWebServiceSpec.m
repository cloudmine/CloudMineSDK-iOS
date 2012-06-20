//
//  CMWebServiceSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <YAJLiOS/YAJL.h>

#import "Kiwi.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#import "NSMutableData+RandomData.h"

#import "CMBlockValidationMessageSpy.h"
#import "CMWebService.h"
#import "CMUser.h"
#import "CMServerFunction.h"
#import "CMAPICredentials.h"

SPEC_BEGIN(CMWebServiceSpec)

describe(@"CMWebService", ^{
    __block NSString *appId = @"appId123";
    __block NSString *appSecret = @"appSecret123";
    __block CMWebService *service = nil;

    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:appId];
        [[CMAPICredentials sharedInstance] setAppSecret:appSecret];
    });
    
    beforeEach(^{
        service = [[CMWebService alloc] init];
        service.networkQueue = [ASINetworkQueue mock];
    });

    context(@"should construct GET request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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
                   serverSideFunction:nil
                        pagingOptions:nil
                        sortingOptions:nil
                                 user:nil
                      extraParameters:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });

        it(@"URLs with a search query at the app level correctly", ^{
            NSString *query = @"[name = \"Marc\"]";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/search?q=%@", appId, [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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

            [service searchValuesFor:query
                  serverSideFunction:nil
                       pagingOptions:nil
                      sortingOptions:nil
                                user:nil
                     extraParameters:nil
                      successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                      } errorHandler:^(NSError *error) {
                      }
             ];
        });

        it(@"binary data URLs at the app level correctly", ^{
            NSString *binaryKey = @"filename";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/binary/%@", appId, binaryKey]];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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

            [service getBinaryDataNamed:binaryKey
                     serverSideFunction:nil
                                   user:nil
                        extraParameters:nil
                         successHandler:^(NSData *data, NSString *contentType, NSDictionary *headers) {
                         } errorHandler:^(NSError *error) {
                         }
             ];
        });

        it(@"JSON URLs at the app level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1,k2", appId]];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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
                   serverSideFunction:nil
                        pagingOptions:nil
                       sortingOptions:nil
                                 user:nil
                      extraParameters:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });

        it(@"JSON URLs at the app level with keys and a server-side function call correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1,k2&f=my_func", appId]];
            CMServerFunction *function = [CMServerFunction serverFunctionWithName:@"my_func"];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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
                   serverSideFunction:function
                        pagingOptions:nil
                       sortingOptions:nil
                                 user:nil
                      extraParameters:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
            creds.token = @"token";

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];

            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];

            [service getValuesForKeys:nil
                   serverSideFunction:nil
                        pagingOptions:nil
                       sortingOptions:nil
                                 user:creds
                      extraParameters:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });

        it(@"binary data URLs at the user level correctly", ^{
            NSString *binaryKey = @"filename";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/binary/%@", appId, binaryKey]];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
            creds.token = @"token";

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
                [[request.requestMethod should] equal:@"GET"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            } forSelector:@selector(addOperation:)];

            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];

            [service getBinaryDataNamed:binaryKey
                     serverSideFunction:nil
                                   user:creds
                        extraParameters:nil
                         successHandler:^(NSData *data, NSString *contentType, NSDictionary *headers) {
                         } errorHandler:^(NSError *error) {
                         }
             ];
        });

        it(@"JSON URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text?keys=k1,k2", appId]];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
            creds.token = @"token";

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
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
                   serverSideFunction:nil
                        pagingOptions:nil
                       sortingOptions:nil
                                 user:creds
                      extraParameters:nil
                       successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });
    });

    context(@"should construct POST request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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
                             serverSideFunction:nil
                                           user:nil
                                extraParameters:nil
                                 successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];
        });

        it(@"binary data URLs at the app level correctly", ^{
            NSString *binaryKey = @"filename";
            NSData *data = [NSMutableData randomDataWithLength:100];
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/binary/%@", appId, binaryKey]];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"PUT"];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[[request requestHeaders] objectForKey:@"Content-Type"] should] equal:@"application/cloudmine"];
                [[request.postBody should] equal:data];
            } forSelector:@selector(addOperation:)];

            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];

            [service uploadBinaryData:data
                   serverSideFunction:nil
                                named:binaryKey
                           ofMimeType:@"application/cloudmine"
                                 user:nil
                      extraParameters:nil
                       successHandler:^(CMFileUploadResult result, NSString *fileKey, id snippetResult, NSDictionary *headers) {
                       }
                         errorHandler:^(NSError *error) {
                         }
             ];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
            creds.token = @"token";

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
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
                             serverSideFunction:nil
                                           user:creds
                                extraParameters:nil
                                 successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];
        });
    });

    it(@"binary data URLs at the user level correctly", ^{
        NSString *binaryKey = @"filename";
        NSData *data = [NSMutableData randomDataWithLength:100];
        CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
        creds.token = @"token";

        NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/binary/%@", appId, binaryKey]];

        id spy = [[CMBlockValidationMessageSpy alloc] init];
        [spy addValidationBlock:^(NSInvocation *invocation) {
            ASIHTTPRequest *request = nil;
            [invocation getArgument:&request atIndex:2]; // only arg is the request
            [[request.url should] equal:expectedUrl];
            [[request.requestMethod should] equal:@"PUT"];
            [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[[request requestHeaders] objectForKey:@"Content-Type"] should] equal:@"application/cloudmine"];
            [[request.postBody should] equal:data];
            [request.username shouldBeNil];
            [request.password shouldBeNil];
            [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
        } forSelector:@selector(addOperation:)];

        // Validate the request when it's pushed onto the network queue so
        // we don't interfere with the construction and use of the request
        // otherwise throughout the production code.
        [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

        [[service.networkQueue should] receive:@selector(addOperation:)];
        [[service.networkQueue should] receive:@selector(go)];

        [service uploadBinaryData:data
               serverSideFunction:nil
                            named:binaryKey
                       ofMimeType:@"application/cloudmine"
                             user:creds
                  extraParameters:nil
                   successHandler:^(CMFileUploadResult result, NSString *fileKey, id snippetResult, NSDictionary *headers) {
                   } errorHandler:^(NSError *error) {
                   }
         ];
    });

    context(@"should construct PUT request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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
                          serverSideFunction:nil
                                        user:nil
                             extraParameters:nil
                              successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                              } errorHandler:^(NSError *error) {
                              }
             ];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
            creds.token = @"token";

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
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
                          serverSideFunction:nil
                                        user:creds
                             extraParameters:nil
                              successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                              } errorHandler:^(NSError *error) {
                              }
             ];
        });
    });

    context(@"should construct DELETE request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data?all=true", appId]];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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
                      serverSideFunction:nil
                                    user:nil
                         extraParameters:nil
                          successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                          } errorHandler:^(NSError *error) {
                          }
             ];
        });

        it(@"JSON URLs at the app level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data?keys=k1,k2&all=true", appId]];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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
                      serverSideFunction:nil
                                    user:nil
                         extraParameters:nil
                          successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                          } errorHandler:^(NSError *error) {
                          }
             ];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data?all=true", appId]];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
            creds.token = @"token";

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
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
                      serverSideFunction:nil
                                    user:creds
                         extraParameters:nil
                          successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                          } errorHandler:^(NSError *error) {
                          }
             ];
        });

        it(@"JSON URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data?keys=k1,k2&all=true", appId]];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
            creds.token = @"token";

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
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
                      serverSideFunction:nil
                                    user:creds
                         extraParameters:nil
                          successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
        });
    });

    context(@"given a user account operation", ^{
        it(@"constructs account creation URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/create", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"POST"];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
                [[[request.postBody yajl_JSON] should] equal:[@"{\"credentials\": {\"email\": \"test@domain.com\", \"password\":\"pass\"}}" yajl_JSON]];
            } forSelector:@selector(addOperation:)];

            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];

            [service createAccountWithUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
        });

        it(@"constructs password change URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/password/change", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];
            user.token = @"token";

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"POST"];
                [[request.username should] equal:user.userId];
                [[request.password should] equal:@"pass"];

                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
            } forSelector:@selector(addOperation:)];

            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];

            [service changePasswordForUser:user oldPassword:@"pass" newPassword:@"newpass" callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
        });

        it(@"constructs password reset URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/password/reset", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:nil];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"POST"];
                [[[request.postBody yajl_JSON] should] equal:[@"{\"email\":\"test@domain.com\"}" yajl_JSON]];
            } forSelector:@selector(addOperation:)];

            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];

            [service resetForgottenPasswordForUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
        });

        it(@"constructs login URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/login", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"POST"];
                [[request.username should] equal:user.userId];
                [[request.password should] equal:user.password];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
            } forSelector:@selector(addOperation:)];

            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];

            [service loginUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
        });

        it(@"constructs logout URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/login", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:9999];

            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
                [invocation getArgument:&request atIndex:2]; // only arg is the request
                [[request.url should] equal:expectedUrl];
                [[request.requestMethod should] equal:@"POST"];
                [request.username shouldBeNil];
                [request.password shouldBeNil];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
                [[[[request requestHeaders] objectForKey:@"X-CloudMine-SessionToken"] should] equal:user.token];
            } forSelector:@selector(addOperation:)];

            // Validate the request when it's pushed onto the network queue so
            // we don't interfere with the construction and use of the request
            // otherwise throughout the production code.
            [service.networkQueue addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(addOperation:)]];

            [[service.networkQueue should] receive:@selector(addOperation:)];
            [[service.networkQueue should] receive:@selector(go)];

            [service logoutUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
        });

        it(@"fetches all users properly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account", appId]];
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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

            [service getAllUsersWithCallback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            }];
        });

        it(@"fetches a user profile by identifier properly", ^{
            NSString *userId = @"1234abcd";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/%@", appId, userId]];
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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

            [service getUserProfileWithIdentifier:userId callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            }];
        });

        it(@"searches user profiles properly", ^{
            NSString *query = @"[name = /Marc/i]";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account?p=%@", appId, [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            id spy = [[CMBlockValidationMessageSpy alloc] init];
            [spy addValidationBlock:^(NSInvocation *invocation) {
                ASIHTTPRequest *request = nil;
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

            [service searchUsers:query callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            }];
        });
    });

});

SPEC_END

