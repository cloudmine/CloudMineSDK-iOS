//
//  CMAPICredentials.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * Convenience singleton class for storing your API key and this app's secret key
 * for communicating with CloudMine web services. If this is configured you do not have to pass either of these
 * strings to the web service methods.
 */
@interface CMAPICredentials : NSObject

/**
 * @return The shared instance of this object.
 */
+ (id)sharedInstance;

/**
 * Convenience method to set both the App ID and the API Key simultaneously.
 */
- (void)setAppIdentifier:(NSString *)appId andApiKey:(NSString *)apiKey;

/**
 * Convenience method to set both the App ID, API Key, and baseURL simultaneously.
 */
- (void)setAppIdentifier:(NSString *)appId apiKey:(NSString *)apiKey andBaseURL:(NSString *)baseURL;


/**
 * The API Key from your CloudMine dashboard.
 * @see https://cloudmine.me/dashboard
 */
@property (nonatomic, copy) NSString *apiKey;

/**
 * @deprecated
 * @see apiKey
 */
@property (nonatomic, copy) NSString *appSecret;

/**
 * The App Identifier from your CloudMine dashboard.
 * @see https://cloudmine.me/dashboard
 */
@property (nonatomic, copy) NSString *appIdentifier;

/**
 * The Base URL you want to use. This will default to the CloudMine main base URL,
 * but if you are using a different stack you can set this to be your stack.
 */
@property (nonatomic, copy) NSString *baseURL;

@end
