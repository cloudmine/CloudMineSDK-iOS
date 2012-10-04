//
//  CMAPICredentials.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMAPICredentials.h"

@implementation CMAPICredentials
@synthesize apiKey = _apiKey, appIdentifier = _appIdentifier;

+ (id)sharedInstance {
    __strong static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)setAppIdentifier:(NSString *)appId andApiKey:(NSString *)apiKey {
    self.appIdentifier = appId;
    self.apiKey = apiKey;
}

#pragma mark - Backwards compatibility

- (NSString *)appSecret {
    return self.apiKey;
}

- (void)setAppSecret:(NSString *)appSecret {
    self.apiKey = appSecret;
}

@end
