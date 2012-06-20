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
        
        spy = [[KWCaptureSpy alloc] initWithArgumentIndex:0];
        
        [NSURLConnection addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(sendAsynchronousRequest:queue:completionHandler:)]];
        [[NSURLConnection should] receive:@selector(sendAsynchronousRequest:queue:completionHandler:)];
    });
    
    afterEach(^{
        [NSURLConnection removeMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:@selector(sendAsynchronousRequest:queue:completionHandler:)]];
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

        it(@"binary data URLs at the user level correctly", ^{
            NSString *binaryKey = @"filename";
            NSURL *expectedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/user/binary/%@", appId, binaryKey]];
            CMUser *creds = [[CMUser alloc] initWithUserId:@"user" andPassword:@"pass"];
            creds.token = @"token";

            [service getBinaryDataNamed:binaryKey
                     serverSideFunction:nil
                                   user:creds
                        extraParameters:nil
                         successHandler:^(NSData *data, NSString *contentType, NSDictionary *headers) {
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
    });

});

SPEC_END

