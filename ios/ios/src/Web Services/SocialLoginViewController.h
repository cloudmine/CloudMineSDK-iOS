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
- (void)socialLoginViewController:(SocialLoginViewController *)controller errorLoggingInToService:(NSString *)service withError:(NSError *)error;

@end

@interface SocialLoginViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (weak, atomic) id<SinglyLoginViewControllerDelegate> delegate;

@property (strong, atomic) NSString *targetService;


/*!
 *
 * Initialize with a service identifier
 *
 * @param service The name of the service that we are logging into.
 */
- (id)initForService:(NSString *)service;

@end

