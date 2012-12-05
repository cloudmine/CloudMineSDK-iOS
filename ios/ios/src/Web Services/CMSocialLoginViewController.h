//
//  SocialLoginViewController.h
//  cloudmine-ios
//
//  Created by Nikko Schaff on 11/12/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMSocialLoginViewController;
@class CMUser;

@protocol CMSocialLoginViewControllerDelegate <NSObject>
- (void)cmSocialLoginViewController:(CMSocialLoginViewController *)controller completeSocialLoginWithChallenge:(NSString *)challenge;
@end

@interface CMSocialLoginViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic,strong) id<CMSocialLoginViewControllerDelegate> delegate;

@property (strong, atomic) NSString *targetService;
@property (strong, atomic) NSString *appID;
@property (strong, atomic) NSString *apiKey;
@property (strong, atomic) NSString *challenge;
@property (strong, atomic) NSString *session_token;
@property (strong, atomic) CMUser *user;



/*!
 *
 * Initialize with a service identifier
 *
 * @param service The name of the service that we are logging into.
 */
- (id)initForService:(NSString *)service withAppID:(NSString *)appID andApiKey:(NSString *)apiKey user:(CMUser *)user;

@end

