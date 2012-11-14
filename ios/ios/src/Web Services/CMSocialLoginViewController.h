//
//  SocialLoginViewController.h
//  cloudmine-ios
//
//  Created by Nikko Schaff on 11/12/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMSocialLoginViewController;

@protocol CMSocialLoginViewControllerDelegate <NSObject>

- (void)cmSocialLoginViewController:(CMSocialLoginViewController *)controller didLoginForService:(NSString *)service;
- (void)cmSocialLoginViewController:(CMSocialLoginViewController *)controller errorLoggingInToService:(NSString *)service withError:(NSError *)error;

@end

@interface CMSocialLoginViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic,strong) id<CMSocialLoginViewControllerDelegate> delegate;

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

