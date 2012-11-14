//
//  SocialLoginViewController.h
//  cloudmine-ios
//
//  Created by Nikko Schaff on 11/12/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SocialLoginViewController;

@protocol SocialLoginViewControllerDelegate <NSObject>

- (void)socialLoginViewController:(SocialLoginViewController *)controller didLoginForService:(NSString *)service;

@end

@interface SocialLoginViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (weak, atomic) id<SocialLoginViewControllerDelegate> delegate;

@property (strong, atomic) NSString *targetService;
@property (strong, atomic) NSString *appID;
@property (strong, atomic) NSString *apiKey;
@property (strong, atomic) NSString *challenge;
@property (strong, atomic) NSString *session_token;


/*!
 *
 * Initialize with a service identifier
 *
 * @param service The name of the service that we are logging into.
 */
- (id)initForService:(NSString *)service withAppID:(NSString *)appID andApiKey:(NSString *)apiKey;
@end

