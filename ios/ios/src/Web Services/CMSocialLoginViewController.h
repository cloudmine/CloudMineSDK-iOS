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

@property (strong, nonatomic) NSString *targetService;
@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *challenge;
@property (strong, nonatomic) NSString *session_token;
@property (strong, nonatomic) NSString *params;
@property (strong, nonatomic) CMUser *user;



/*!
 *
 * Initialize with a service identifier
 *
 * @param service The name of the service that we are logging into
 * @param appID The appID gotten from the dashboard
 * @param apiKey The APIKey from the dashboard for your application
 * @param user Can be nil, the user you want to link accounts with. If this parameter is nil, we will not link the accounts. If you pass in the user, we will attempt to link the accounts.
 * @param params Any extra params you want passed on to the end of the URL. This is how we put the scope in for certain requests. Because difference services handle scope differently, the user must do the encoding for this string.
 */
- (id)initForService:(NSString *)service appID:(NSString *)appID apiKey:(NSString *)apiKey user:(CMUser *)user params:(NSString *)params;

@end

