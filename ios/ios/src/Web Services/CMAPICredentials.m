//
//  CMAPICredentials.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMAPICredentials.h"
#import "CMConstants.h"

@implementation CMAPICredentials

+ (id)sharedInstance;
{
    __strong static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)setAppIdentifier:(NSString *)appId andApiKey:(NSString *)apiKey;
{
    [self setAppIdentifier:appId apiKey:apiKey andBaseURL:nil];
}

- (void)setAppIdentifier:(NSString *)appId apiKey:(NSString *)apiKey andBaseURL:(NSString *)baseURL;
{
    self.appIdentifier = appId;
    self.apiKey = apiKey;
    self.baseURL = baseURL;
}

- (NSString *)baseURL;
{
    if (!_baseURL) {
        return CM_BASE_URL;
    }
    return _baseURL;
}

#pragma mark - Backwards compatibility

- (NSString *)appSecret;
{
    return self.apiKey;
}

- (void)setAppSecret:(NSString *)appSecret;
{
    self.apiKey = appSecret;
}

@end
