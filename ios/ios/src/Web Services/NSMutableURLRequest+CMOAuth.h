//
//  NSMutableURLRequest+OAuth.h
//  EMSupport
//
//  Created by Ethan Mick on 6/25/14.
//  Copyright (c) 2014 Ethan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (CMOAuth)

+ (NSMutableURLRequest *)requestWithURL:(NSURL *)URL
                             parameters:(NSDictionary *)parameters
                                 method:(NSString *)urlMethod
                            consumerKey:(NSString *)consumerKey
                              secretKey:(NSString *)secretKey
                              authToken:(NSString *)token
                        authTokenSecret:(NSString *)authTokenSecret;


extern NSString *OAuthorizationHeader(NSURL *url,
                                      NSString *method,
                                      NSData *body,
                                      NSString *_oAuthConsumerKey,
                                      NSString *_oAuthConsumerSecret,
                                      NSString *_oAuthToken,
                                      NSString *_oAuthTokenSecret);


@end
