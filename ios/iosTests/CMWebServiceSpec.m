//
//  CMWebServiceSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <YAJLiOS/YAJL.h>

#import "Kiwi.h"

#import "NSMutableData+RandomData.h"
#import "NSData+Base64.h"

#import "CMWebService.h"
#import "CMObjectSerialization.h"
#import "CMUser.h"
#import "CMServerFunction.h"
#import "CMAPICredentials.h"

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
        [service setValue:@"https://api.cloudmine.me/v1" forKey:@"apiUrl"];
        
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
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1,k2", appId]];

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
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/text?keys=k1,k2&f=my_func", appId]];
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
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text?keys=k1,k2", appId]];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            [[[[request HTTPBody] yajl_JSON] should] equal:dataToPost];
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
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            [[[[request HTTPBody] yajl_JSON] should] equal:dataToPost];
        });
        
        it(@"ACL URLs correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/access", appId]];
            NSMutableDictionary *aclDict = [[NSMutableDictionary alloc] init];
            [aclDict setObject:@"val1" forKey:@"key1"];
            [aclDict setObject:@"val2" forKey:@"key2"];
            [aclDict setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            [[[[request HTTPBody] yajl_JSON] should] equal:aclDict];
        });
    });

    it(@"binary data URLs at the user level correctly", ^{
        NSString *binaryKey = @"filename";
        NSData *data = [NSMutableData randomDataWithLength:100];
        CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            [[[[request HTTPBody] yajl_JSON] should] equal:dataToPost];
        });

        it(@"JSON URLs at the user level correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/text", appId]];
            NSMutableDictionary *dataToPost = [[NSMutableDictionary alloc] init];
            [dataToPost setObject:@"val1" forKey:@"key1"];
            [dataToPost setObject:@"val2" forKey:@"key2"];
            [dataToPost setObject:[NSArray arrayWithObjects:@"arrVal1", @"arrVal2", nil] forKey:@"arrKey1"];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            [[[[request HTTPBody] yajl_JSON] should] equal:dataToPost];
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
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/data?keys=k1,k2&all=true", appId]];

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
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/data?keys=k1,k2&all=true", appId]];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
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
        it(@"constructs account creation URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/create", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];

            [service createAccountWithUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldBeNil];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
            
            NSDictionary *requestBody = [[request HTTPBody] yajl_JSON];
            [[[requestBody objectForKey:@"credentials"] should] haveValue:@"test@domain.com" forKey:@"email"];
            [[[requestBody objectForKey:@"credentials"] should] haveValue:@"pass" forKey:@"password"];
        });

        it(@"constructs password change URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/password/change", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];
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
            
            [[[components objectAtIndex:0] should] equal:user.userId];
            [[[components objectAtIndex:1] should] equal:password];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
            [[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-SessionToken"] shouldBeNil];
        });

        it(@"constructs password reset URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/password/reset", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:nil];

            [service resetForgottenPasswordForUser:user callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"POST"];
            [[[[request HTTPBody] yajl_JSON] should] equal:[@"{\"email\":\"test@domain.com\"}" yajl_JSON]];
        });

        it(@"constructs login URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/login", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];
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
            
            [[[components objectAtIndex:0] should] equal:user.userId];
            [[[components objectAtIndex:1] should] equal:password];
        });

        it(@"constructs logout URL correctly", ^{
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/logout", appId]];
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];
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
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/search?p=%@", appId, [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            [service searchUsers:query callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            }];
            
            NSURLRequest *request = spy.argument;
            [[[request URL] should] equal:expectedUrl];
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request allHTTPHeaderFields] objectForKey:@"X-CloudMine-ApiKey"] should] equal:appSecret];
        });
        
        it(@"Contructs the Social Query Properly", ^{
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];
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
            
            NSString *finalURLShould = $sprintf(@"https://api.cloudmine.me/v1/app/%@/user/social/twitter/statuses/user_timeline.json?params={\"count\":9,\"screen_name\":\"ethan_mick\"}", appId);
            finalURLShould = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                        kCFAllocatorDefault,
                                                                                        (CFStringRef)finalURLShould,
                                                                                        NULL,
                                                                                        NULL,
                                                                                        kCFStringEncodingUTF8
                                                                                        );

            NSURLRequest *request = spy.argument;
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request URL] absoluteString] should] equal:finalURLShould];
            
            
        });
        
        it(@"should properly deal with arrays in social queries", ^{
            
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];
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
            
            NSString *finalURLShould = $sprintf(@"https://api.cloudmine.me/v1/app/%@/user/social/twitter/statuses/user_timeline.json?params={\"screen_name\":\"ethan_mick\",\"testing\":[\"Testing111\",\"Testing222\"]}", appId);
            finalURLShould = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          kCFAllocatorDefault,
                                                                                          (CFStringRef)finalURLShould,
                                                                                          NULL,
                                                                                          NULL,
                                                                                          kCFStringEncodingUTF8
                                                                                          );
            
            
            NSURLRequest *request = spy.argument;
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request URL] absoluteString] should] equal:finalURLShould];
        });
        
        it(@"should properly encode the POST data in social queries", ^{
            
            NSData *data = [@"status=Maybe he'll finally find his keys. #peterfalk" dataUsingEncoding:NSUTF8StringEncoding];
            
            CMUser *user = [[CMUser alloc] initWithUserId:@"test@domain.com" andPassword:@"pass"];
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

            
            NSString *finalURLShould = $sprintf(@"https://api.cloudmine.me/v1/app/%@/user/social/twitter/statuses/update.json?headers={\"Content-type\":\"application/x-www-form-urlencoded\"}", appId);
            finalURLShould = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          kCFAllocatorDefault,
                                                                                          (CFStringRef)finalURLShould,
                                                                                          NULL,
                                                                                          NULL,
                                                                                          kCFStringEncodingUTF8
                                                                                          );
            
            
            NSURLRequest *request = spy.argument;
            [[[request HTTPMethod] should] equal:@"GET"];
            [[[[request URL] absoluteString] should] equal:finalURLShould];
            [[[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] should] equal:@"status=Maybe he'll finally find his keys. #peterfalk"];
        });
    });
    
    context(@"given a push notification operation", ^{
        it(@"sends the correct dev token", ^{
            
            NSString *token = @"<c7e265d1 cbd443b3 ee80fd07 c892a8b8 f20c08c4 91fa11f2 535f2cca ad7f55ef>";
            
            [service registerForPushNotificationsWithUser:nil token:token callback:^(CMDeviceTokenResult result) {}];
            
            NSURLRequest *request = spy.argument;
            
            NSDictionary *requestBody = [[request HTTPBody] yajl_JSON];
            [[[requestBody valueForKey:@"token"] should] equal:@"c7e265d1cbd443b3ee80fd07c892a8b8f20c08c491fa11f2535f2ccaad7f55ef"];
            
            
        });
        
        it(@"correctly sends the deregister request", ^{
            
            [service unRegisterForPushNotificationsWithUser:nil callback:^(CMDeviceTokenResult result) { }];
            
            NSURLRequest *request = spy.argument;
            
            [[[[request URL] absoluteString] should] equal:$sprintf(@"https://api.cloudmine.me/v1/app/%@/device", appId)];
            [[[request HTTPMethod] should] equal:@"DELETE"];
        });
    });
});

SPEC_END

