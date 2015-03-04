//
//  CMWebServiceSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "NSMutableData+RandomData.h"
#import "NSData+Base64.h"

#import "CMWebService.h"
#import "CMObjectSerialization.h"
#import "CMUser.h"
#import "CMServerFunction.h"
#import "CMAPICredentials.h"
#import "CMConstants.h"
#import "NSDictionary+CMJSON.h"
#import "CMStore.h"

SPEC_BEGIN(CMWebServiceSpec)

describe(@"CMWebService", ^{
    __block NSString *appId = @"appId123";
    __block NSString *appSecret = @"appSecret123";
    __block CMWebService *service = nil;
    __block KWCaptureSpy *spy = nil;
    
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:appId];
        [[CMAPICredentials sharedInstance] setAppSecret:appSecret];
    });

    beforeEach(^{
        service = [[CMWebService alloc] init];
        [service setValue:@"https://api.cloudmine.me/" forKey:@"apiUrl"];
        
        spy = [[KWCaptureSpy alloc] initWithArgumentIndex:0];
        
        [service addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(HTTPRequestOperationWithRequest:success:failure:)]];
        [[service should] receive:@selector(enqueueHTTPRequestOperation:)];
    });
    
    afterEach(^{
        [service removeMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(HTTPRequestOperationWithRequest:success:failure:)]];
    });

    context(@"should construct GET request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];

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
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];            
        });

        it(@"URLs with a search query at the app level correctly", ^{
            NSString *query = @"[name = \"Marc\"]";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/search?q=%@", appId, [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

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
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];            
        });

        it(@"binary data URLs at the app level correctly", ^{
            NSString *binaryKey = @"filename";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/binary/%@", appId, binaryKey]];

            [service getBinaryDataNamed:binaryKey
                     serverSideFunction:nil
                                   user:nil
                        extraParameters:nil
                         successHandler:^(NSData *data, NSString *contentType, NSDictionary *headers) {
                         } errorHandler:^(NSError *error) {
                         }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];            
        });

        it(@"JSON URLs at the app level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1%%2Ck2", appId]];

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
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"JSON URLs at the app level with keys and a server-side function call correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1%%2Ck2&f=my_func", appId]];
            CMServerFunction *function = [CMServerFunction serverFunctionWithName:@"my_func"];

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
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";

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
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
        
        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";
            
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
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"JSON URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text?keys=k1%%2Ck2", appId]];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";

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
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
        
        it(@"ACL URLs correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/access", appId]];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";
            
            [service getACLsForUser:creds
                     successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                     } errorHandler:^(NSError *error) {
                     }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
        
        it(@"ACL URLs with a search query correctly", ^{
            NSString *query = @"[key=\"value\"]";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/access/search?q=%@", appId, [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";
            
            [service searchACLs:query
                           user:creds
                 successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                 } errorHandler:^(NSError *error) {
                 }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
    });

    context(@"should construct POST request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];

            [service updateValuesFromDictionary:dataToPost
                             serverSideFunction:nil
                                           user:nil
                                extraParameters:nil
                                 successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"binary data URLs at the app level correctly", ^{
            NSString *binaryKey = @"filename";
            NSData *data = [NSMutableData randomDataWithLength:100];
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/binary/%@", appId, binaryKey]];

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
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"PUT"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/cloudmine"];
            [[[request HTTPBody] should] equal:data];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";

            [service updateValuesFromDictionary:dataToPost
                             serverSideFunction:nil
                                           user:creds
                                extraParameters:nil
                                 successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                                 } errorHandler:^(NSError *error) {
                                 }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
        
        it(@"ACL URLs correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/access", appId]];
            NSMutableDictionary *aclDict = [[NSMutableDictionary alloc] init];
            [aclDict setObject:@"val1" forKey:@"key1"];
            [aclDict setObject:@"val2" forKey:@"key2"];
            [aclDict setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";
            
            [service updateACL:aclDict
                          user:creds
                successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                } errorHandler:^(NSError *error) {
                }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
    });

    it(@"binary data URLs at the user level correctly", ^{
        NSString *binaryKey = @"filename";
        NSData *data = [NSMutableData randomDataWithLength:100];
        CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
        creds.token = @"token";

        NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/binary/%@", appId, binaryKey]];

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
        
        NSURLRequest *request = spy.argument;
        [[[request URL] should] equal:expectedUrl];
        [[[request HTTPMethod] should] equal:@"PUT"];
        [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/cloudmine"];
        [[[request HTTPBody] should] equal:data];
        [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
        [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];        
    });

    context(@"should construct PUT request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];

            [service setValuesFromDictionary:dataToPost
                          serverSideFunction:nil
                                        user:nil
                             extraParameters:nil
                              successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                              } errorHandler:^(NSError *error) {
                              }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"PUT"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";

            [service setValuesFromDictionary:dataToPost
                          serverSideFunction:nil
                                        user:creds
                             extraParameters:nil
                              successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                              } errorHandler:^(NSError *error) {
                              }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"PUT"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
    });

    context(@"should construct DELETE request", ^{
        it(@"JSON URLs at the app level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data?all=true", appId]];

            [service deleteValuesForKeys:nil
                      serverSideFunction:nil
                                    user:nil
                         extraParameters:nil
                          successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                          } errorHandler:^(NSError *error) {
                          }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"DELETE"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"JSON URLs at the app level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data?keys=k1%%2Ck2&all=true", appId]];

            [service deleteValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                      serverSideFunction:nil
                                    user:nil
                         extraParameters:nil
                          successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                          } errorHandler:^(NSError *error) {
                          }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"DELETE"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data?all=true", appId]];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";

            [service deleteValuesForKeys:nil
                      serverSideFunction:nil
                                    user:creds
                         extraParameters:nil
                          successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                          } errorHandler:^(NSError *error) {
                          }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"DELETE"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"JSON URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data?keys=k1%%2Ck2&all=true", appId]];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";

            [service deleteValuesForKeys:[NSArray arrayWithObjects:@"k1", @"k2", nil]
                      serverSideFunction:nil
                                    user:creds
                         extraParameters:nil
                          successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"DELETE"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
        
        it(@"JSON URLs at the user level with keys correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/access/k1", appId]];
            CMUser *creds = [[CMUser alloc] initWithEmail:@"user@test.com" andPassword:@"pass"];
            creds.token = @"token";
            
            [service deleteACLWithKey:@"k1"
                                 user:creds
                       successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
                       } errorHandler:^(NSError *error) {
                       }
             ];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:creds.token];
            [[[request HTTPMethod] should] equal:@"DELETE"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
    });

    context(@"given a user account operation", ^{
        
        __block CMUser *testUser = nil;
        beforeEach(^{
            testUser = [[CMUser alloc] initWithEmail:@"a_test_email@cloudmine.me" andPassword:@"testing"];
            testUser.token = @"token";
            testUser.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000];
            testUser.password = @"testing";
        });
        
        it(@"constructs account creation URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/create", appId]];
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:@"pass"];

            [service createAccountWithUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
            
            NSDictionary *requestBody = [NSJSONSerialization JSONObjectWithData:[request HTTPBody] options:0 error:nil];
            [[[requestBody objectForKey:@"credentials"] should] haveValue:@"test@domain.com" forKey:@"email"];
            [[[requestBody objectForKey:@"credentials"] should] haveValue:@"pass" forKey:@"password"];
        });

        it(@"constructs password change URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/credentials", appId]];
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:@"pass"];
            NSString *password = user.password;
            user.token = @"token";

            [service changePasswordForUser:user oldPassword:@"pass" newPassword:@"newpass" callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"POST"];
            
            NSData *authData = [NSData dataFromBase64String:[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] stringByReplacingOccurrencesOfString:@"Basic " withString:@""]];
            NSArray *components = [[[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding] componentsSeparatedByString:@":"];
            [[[NSNumber numberWithUnsignedInteger:components.count] should] equal:[NSNumber numberWithUnsignedInt:2]];
            
            [[[components objectAtIndex:0] should] equal:user.email];
            [[[components objectAtIndex:1] should] equal:password];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
        });
        
        it(@"constructs credentials update URL correctly", ^{
            
            NSURL *expectedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/credentials", appId]];
            CMUser *user = [[CMUser alloc] initWithEmail:@"test-2@domain.com" andPassword:@"password"];
            NSString *password = user.password;
            user.token = @"token";
            
            [service changeCredentialsForUser:user password:@"password" newPassword:@"aNewPassword" newUsername:nil newEmail:nil callback:^(CMUserAccountResult result, NSDictionary *responseBody) {}];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedURL];
            [[[request HTTPMethod] should] equal:@"POST"];
            
            NSData *authData = [NSData dataFromBase64String:[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] stringByReplacingOccurrencesOfString:@"Basic " withString:@""]];
            NSArray *components = [[[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding] componentsSeparatedByString:@":"];
            [[[NSNumber numberWithUnsignedInteger:components.count] should] equal:[NSNumber numberWithUnsignedInt:2]];
            
            [[[components objectAtIndex:0] should] equal:user.email];
            [[[components objectAtIndex:1] should] equal:password];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
        });
        
        it(@"should call the correct credentials method", ^{
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test-2@domain.com" andPassword:@"password"];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[theBlock(^{
                [service changeCredentialsForUser:user
                                         password:@"password"
                                      newPassword:@"password2"
                                      newUsername:nil
                                        newUserId:nil
                                         callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
                                             
                                         }];
            }) shouldNot] raise];
           
#pragma clang diagnostic pop
        });
        
        it(@"constructs credentials update URL payload correctly", ^{
            NSURL *expectedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/credentials", appId]];
            CMUser *user = [[CMUser alloc] initWithUsername:@"awesomeUsername" andPassword:@"password"];
            NSString *password = user.password;
            user.token = @"token";
            
            [service changeCredentialsForUser:user password:@"password" newPassword:nil newUsername:@"aNewUsername" newEmail:@"aNewUserID" callback:^(CMUserAccountResult result, NSDictionary *responseBody) {}];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedURL];
            [[[request HTTPMethod] should] equal:@"POST"];
            
            NSData *authData = [NSData dataFromBase64String:[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] stringByReplacingOccurrencesOfString:@"Basic " withString:@""]];
            NSArray *components = [[[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding] componentsSeparatedByString:@":"];
            [[[NSNumber numberWithUnsignedInteger:components.count] should] equal:[NSNumber numberWithUnsignedInt:2]];
            
            [[[components objectAtIndex:0] should] equal:user.username];
            [[[components objectAtIndex:1] should] equal:password];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
            
            [[[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] should] equal:[@{@"username" : @"aNewUsername", @"email" : @"aNewUserID"} jsonString]];
        });


        it(@"constructs password reset URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/password/reset", appId]];
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:nil];

            [service resetForgottenPasswordForUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"POST"];
        });

        it(@"constructs login URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/login", appId]];
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:@"pass"];
            NSString *password = user.password;
            
            [service loginUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
            
            NSData *authData = [NSData dataFromBase64String:[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] stringByReplacingOccurrencesOfString:@"Basic " withString:@""]];
            NSArray *components = [[[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding] componentsSeparatedByString:@":"];
            [[[NSNumber numberWithUnsignedInteger:components.count] should] equal:[NSNumber numberWithUnsignedInt:2]];
            
            [[[components objectAtIndex:0] should] equal:user.email];
            [[[components objectAtIndex:1] should] equal:password];
        });

        it(@"constructs logout URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/logout", appId]];
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:@"pass"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:9999];

            [service logoutUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] should] equal:user.token];
        });

        it(@"fetches all users properly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account", appId]];
            [service getAllUsersWithCallback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"fetches a user profile by identifier properly", ^{
            NSString *userId = @"1234abcd";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/%@", appId, userId]];
            
            [service getUserProfileWithIdentifier:userId callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });

        it(@"searches user profiles properly", ^{
            NSString *query = @"[name = /Marc/i]";
            NSURL *expected = [NSURL URLWithString:@"https://api.cloudmine.me/v1/app/appId123/account/search?p=%5Bname%20%3D%20%2FMarc%2Fi%5D"];
            
            [service searchUsers:query callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expected];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
        
        it(@"Contructs the Social Query Properly", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:@"pass"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:9999];
            
            [service runSocialGraphQueryOnNetwork:CMSocialNetworkTwitter
                                         withVerb:@"GET"
                                        baseQuery:@"statuses/user_timeline.json"
                                       parameters:@{@"screen_name":@"ethan_mick",@"count":@9}
                                          headers:nil
                                      messageData:nil
                                         withUser:user
                                    successHandler:^(NSString *results, NSDictionary *headers) {
                                        
                                    } errorHandler:^(NSError *error) {
                                        
                                    }];
            
            NSString *finalURLShould = @"https://api.cloudmine.me/v1/app/appId123/user/social/twitter/statuses/user_timeline.json?params=%7B%22count%22%3A9%2C%22screen_name%22%3A%22ethan_mick%22%7D";
            
            NSURLRequest *request = spy.argument;
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request URL] absoluteString] should] equal:finalURLShould];
        });
        
        it(@"should call the social query correctly", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:@"pass"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:9999];
            
            KWCaptureSpy *spy = [service captureArgument:@selector(runSocialGraphQueryOnNetwork:withVerb:baseQuery:parameters:headers:messageData:withUser:successHandler:errorHandler:) atIndex:1];
            
            [service runSocialGraphGETQueryOnNetwork:CMSocialNetworkTwitter
                                           baseQuery:@"feed.json"
                                          parameters:nil
                                             headers:nil
                                            withUser:user
                                      successHandler:nil
                                        errorHandler:nil];
            
            [[spy.argument should] equal:@"GET"];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly deal with arrays in social queries", ^{
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:@"pass"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:9999];
            
            [service runSocialGraphQueryOnNetwork:CMSocialNetworkTwitter
                                         withVerb:@"GET"
                                        baseQuery:@"statuses/user_timeline.json"
                                       parameters:@{@"screen_name":@"ethan_mick",@"testing":@[@"Testing111", @"Testing222"]}
                                          headers:nil
                                      messageData:nil
                                         withUser:user
                                    successHandler:^(NSString *results, NSDictionary *headers) {
                                        
                                    } errorHandler:^(NSError *error) {
                                        
                                    }];
            
            NSURLRequest *request = spy.argument;
            [[[request HTTPMethod] should] equal:@"GET"];
            NSString *url = [[request URL] absoluteString];
            [[url should] containString:@"https://api.cloudmine.me/v1/app/appId123/user/social/twitter/statuses/user_timeline.json"];
            [[url should] containString:@"%22screen_name%22%3A%22ethan_mick%22"];
            [[url should] containString:@"%22testing%22%3A%5B%22Testing111%22"];
            [[url should] containString:@"%22Testing222%22%5D"];
        });
        
        it(@"should properly encode the POST data in social queries", ^{
            
            NSData *data = [@"status=Maybe he'll finally find his keys. #peterfalk" dataUsingEncoding:NSUTF8StringEncoding];
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"test@domain.com" andPassword:@"pass"];
            user.token = @"token";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:9999];
            
            [service runSocialGraphQueryOnNetwork:CMSocialNetworkTwitter
                                         withVerb:@"GET"
                                        baseQuery:@"statuses/update.json"
                                       parameters:nil
                                          headers:@{@"Content-type" : @"application/x-www-form-urlencoded"}
                                      messageData:data
                                         withUser:user
                                    successHandler:^(NSString *results, NSDictionary *headers) {
                                        
                                    } errorHandler:^(NSError *error) {
                                        
                                    }];

            
            NSString *finalURLShould = @"https://api.cloudmine.me/v1/app/appId123/user/social/twitter/statuses/update.json?headers=%7B%22Content-type%22%3A%22application%5C%2Fx-www-form-urlencoded%22%7D";
            NSURLRequest *request = spy.argument;
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request URL] absoluteString] should]  equal:finalURLShould];
            [[[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] should] equal:@"status=Maybe he'll finally find his keys. #peterfalk"];
        });
        
        it(@"should properly look at the error domain on login", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service loginUser:testUser callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
                
            }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorUnauthorized userInfo:@{}]);
            [[ theValue(res) should] equal:theValue(CMUserAccountLoginFailedIncorrectCredentials)];
            
            CMUserAccountResult res2 = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorServerConnectionFailed userInfo:@{}]);
            [[ theValue(res2) should] equal:theValue(CMUserAccountUnknownResult)];
            
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly look at the error domain on logout", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service logoutUser:testUser callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res2 = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorServerConnectionFailed userInfo:@{}]);
            [[ theValue(res2) should] equal:theValue(CMUserAccountUnknownResult)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly look at the error domain on create account", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            CMUser *user = [[CMUser alloc] initWithEmail:@"randomer@cloudmine.me" andPassword:@"testing"];
            [service createAccountWithUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res2 = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorServerConnectionFailed userInfo:@{}]);
            [[ theValue(res2) should] equal:theValue(CMUserAccountUnknownResult)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly look at the error domain on social login", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service cmSocialLoginViewController:nil completeSocialLoginWithChallenge:@"challenge"];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorUnauthorized userInfo:@{}]);
            [[ theValue(res) should] equal:theValue(CMUserAccountLoginFailedIncorrectCredentials)];
            
            CMUserAccountResult res2 = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorServerConnectionFailed userInfo:@{}]);
            [[ theValue(res2) should] equal:theValue(CMUserAccountUnknownResult)];
            
            CMUserAccountResult res3 = callback(200, nil);
            [[ theValue(res3) should] equal:theValue(CMUserAccountLoginSucceeded)];
            
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly look at the error domain on change credentials", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service changeCredentialsForUser:testUser
                                     password:@"testing"
                                  newPassword:@"testing2"
                                  newUsername:@"user"
                                     newEmail:@"email@cloudmine.me"
                                     callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorUnauthorized userInfo:@{}]);
            [[ theValue(res) should] equal:theValue(CMUserAccountPasswordChangeFailedInvalidCredentials)];
            
            CMUserAccountResult res2 = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorServerConnectionFailed userInfo:@{}]);
            [[ theValue(res2) should] equal:theValue(CMUserAccountUnknownResult)];
            
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly map the error codes on credential change for password", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service changeCredentialsForUser:testUser
                                     password:@"testing"
                                  newPassword:@"testing2"
                                  newUsername:nil
                                     newEmail:nil
                                     callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(401, nil);
            [[ theValue(res) should] equal:theValue(CMUserAccountPasswordChangeFailedInvalidCredentials)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly map the error codes on credential change for credentials", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service changeCredentialsForUser:testUser
                                     password:@"testing"
                                  newPassword:@"testing2"
                                  newUsername:@"newemail@cloudmine.me"
                                     newEmail:nil
                                     callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(401, nil);
            [[ theValue(res) should] equal:theValue(CMUserAccountCredentialChangeFailedInvalidCredentials)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly map the error codes on credential change for unknown account", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service changeCredentialsForUser:testUser
                                     password:@"testing"
                                  newPassword:@"testing2"
                                  newUsername:@"newemail@cloudmine.me"
                                     newEmail:nil
                                     callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(404, nil);
            [[ theValue(res) should] equal:theValue(CMUserAccountOperationFailedUnknownAccount)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly map the error codes on credential change for duplicate info", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service changeCredentialsForUser:testUser
                                     password:@"testing"
                                  newPassword:nil
                                  newUsername:@"newemail@cloudmine.me"
                                     newEmail:@"username"
                                     callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(409, nil);
            [[ theValue(res) should] equal:theValue(CMUserAccountCredentialChangeFailedDuplicateInfo)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly map the error codes on credential change for duplicate email", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service changeCredentialsForUser:testUser
                                     password:@"testing"
                                  newPassword:nil
                                  newUsername:nil
                                     newEmail:@"newemail@cloudmine.me"
                                     callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(409, nil);
            [[ theValue(res) should] equal:theValue(CMUserAccountCredentialChangeFailedDuplicateEmail)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly map the error codes on credential change for duplicate username", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service changeCredentialsForUser:testUser
                                     password:@"testing"
                                  newPassword:nil
                                  newUsername:@"username"
                                     newEmail:nil
                                     callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(409, nil);
            [[ theValue(res) should] equal:theValue(CMUserAccountCredentialChangeFailedDuplicateUsername)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly map the error codes on credential change for password", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service changeCredentialsForUser:testUser
                                     password:@"testing"
                                  newPassword:@"conflict"
                                  newUsername:nil
                                     newEmail:nil
                                     callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            CMUserAccountResult res = callback(409, nil);
            [[ theValue(res) should] equal:theValue(CMUserAccountCredentialChangeFailedDuplicateInfo)];
            [service enqueueHTTPRequestOperation:nil];
        });
        
        it(@"should properly look at the error domain on reset password email", ^{
            
            KWCaptureSpy *spy = [service captureArgument:NSSelectorFromString(@"executeUserAccountActionRequest:codeMapper:callback:") atIndex:1];
            
            [service resetForgottenPasswordForUser:testUser callback:^(CMUserAccountResult result, NSDictionary *responseBody) { }];
            
            CMUserAccountResult (^callback) (NSUInteger httpResponseCode, NSError *error) = spy.argument;
            
            CMUserAccountResult res2 = callback(0, [NSError errorWithDomain:@"CMErrorDomain" code:CMErrorServerConnectionFailed userInfo:@{}]);
            [[ theValue(res2) should] equal:theValue(CMUserAccountUnknownResult)];
            
            CMUserAccountResult res3 = callback(200, nil);
            [[theValue(res3) should] equal:theValue(CMUserAccountPasswordResetEmailSent)];
            
            CMUserAccountResult res4 = callback(404, nil);
            [[theValue(res4) should] equal:theValue(CMUserAccountOperationFailedUnknownAccount)];
            
            CMUserAccountResult res5 = callback(500, nil);
            [[theValue(res5) should] equal:theValue(CMUserAccountUnknownResult)];
            
            [service enqueueHTTPRequestOperation:nil];
        });
        
    });
    
    context(@"given a push notification operation", ^{
        
        it(@"sends the correct dev token", ^{
            
            NSString *token = @"<c7e265d1 cbd443b3 ee80fd07 c892a8b8 f20c08c4 91fa11f2 535f2cca ad7f55ef>";
            
            [service registerForPushNotificationsWithUser:nil token:(NSData *)token callback:^(CMDeviceTokenResult result) {}];
            
            NSURLRequest *request = spy.argument;
            NSDictionary *requestBody = [NSJSONSerialization JSONObjectWithData:[request HTTPBody] options:0 error:nil];
            [[[requestBody valueForKey:@"token"] should] equal:@"c7e265d1cbd443b3ee80fd07c892a8b8f20c08c491fa11f2535f2ccaad7f55ef"];
        });
        
        it(@"should return an error enum when a bad request is received", ^{
            
            KWCaptureSpy *callbackBlockSpy = [service captureArgument:NSSelectorFromString(@"executeRequest:resultHandler:") atIndex:1];
            [[service should] receive:NSSelectorFromString(@"executeRequest:resultHandler:") withCount:1];
            
            NSString *token = @"<c7e265d1 cbd443b3 ee80fd07 c892a8b8 f20c08c4 91fa11f2 535f2cca ad7f55ef>";
            [service registerForPushNotificationsWithUser:nil token:(NSData *)token callback:^(CMDeviceTokenResult result) {
                [[theValue(result) should] equal:theValue(CMDeviceTokenOperationFailed)];
            }];
            
            CMWebServiceResultCallback callback = callbackBlockSpy.argument;
            callback(@{}, nil, 400);
            [service enqueueHTTPRequestOperation:nil]; //so it doesn't fail
        });
        
        it(@"correctly sends the deregister request", ^{
            
            [service unRegisterForPushNotificationsWithUser:nil callback:^(CMDeviceTokenResult result) { }];
            
            NSURLRequest *request = spy.argument;
            
            [[[[request URL] absoluteString] should] equal:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/device", appId]];;
            [[[request HTTPMethod] should] equal:@"DELETE"];
        });
        
        
        context(@"given push channels", ^{
            
            __block CMWebService *pushService = nil;
            __block KWCaptureSpy *pushSpy = nil;
            beforeEach(^{
                pushService = [[CMWebService alloc] init];
                pushSpy = [[KWCaptureSpy alloc] initWithArgumentIndex:1];
                [pushService addMessageSpy:pushSpy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(getChannelsForDevice:callback:)]];
            });
            
            it(@"shows the user channels as nil", ^{

                [pushService getChannelsForDevice:@"device" callback:^(CMViewChannelsResponse *response) {
                    [[response.channels should] beNil];
                }];
                
                CMViewChannelsRequestCallback callback = pushSpy.argument;
                CMViewChannelsResponse *response = [[CMViewChannelsResponse alloc] initWithResponseBody:@{} httpCode:200 error:nil];
                callback(response);
                [service enqueueHTTPRequestOperation:nil];
            });
            
            it(@"shows the user channels as empty if it's an array", ^{
                
                [pushService getChannelsForDevice:@"device" callback:^(CMViewChannelsResponse *response) {
                }];
                
                CMViewChannelsRequestCallback callback = pushSpy.argument;
                CMViewChannelsResponse *response = [[CMViewChannelsResponse alloc] initWithResponseBody:@[] httpCode:200 error:nil];
                callback(response);
                [service enqueueHTTPRequestOperation:nil];
            });
            
            afterEach(^{
                [pushService removeMessageSpy:pushSpy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(getChannelsForDevice:callback:)]];
            });
        });
    });
});

describe(@"CMWebServiceBaseUrl", ^{
    context(@"base url changing", ^{
        it(@"should let the base URL be correctly set", ^{
            
            NSURL *newBaseUrl = [NSURL URLWithString:@"https://test.api.cloudmine.me"];
            CMWebService *newService = [[CMWebService alloc] initWithAppSecret:@"test" appIdentifier:@"testing" baseURL:newBaseUrl];
            
            NSString *expected = [[newBaseUrl URLByAppendingPathComponent:CM_DEFAULT_API_VERSION] absoluteString];
            [[[newService valueForKey:@"apiUrl"] shouldNot] beNil];
            [[[newService valueForKey:@"apiUrl"] should] equal:expected];
        });
        
        it(@"should properly get the base URL from CMAPICredentials", ^{
            
            NSURL *newBaseUrl = [NSURL URLWithString:@"https://test.api.cloudmine.me"];
            [[CMAPICredentials sharedInstance] setBaseURL:newBaseUrl.absoluteString];
            CMWebService *newService = [[CMWebService alloc] initWithAppSecret:@"test" appIdentifier:@"testing"];
            
            NSString *expected = [[newBaseUrl URLByAppendingPathComponent:CM_DEFAULT_API_VERSION] absoluteString];
            [[[newService valueForKey:@"apiUrl"] shouldNot] beNil];
            [[[newService valueForKey:@"apiUrl"] should] equal:expected];
        });
    });
    
});

SPEC_END

