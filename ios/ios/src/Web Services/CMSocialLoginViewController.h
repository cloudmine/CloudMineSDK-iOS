//
//  SocialLoginViewController.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
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
@property (strong, nonatomic) NSDictionary *params;
@property (strong, nonatomic) CMUser *user;



/*!
 *
 * Initialize with a service identifier
 *
 * @param service The name of the service that we are logging into
 * @param appID The appID gotten from the dashboard
 * @param apiKey The APIKey from the dashboard for your application
 * @param user Can be nil, the user you want to link accounts with. If this parameter is nil, we will not link the accounts. If you pass in the user, we will attempt to link the accounts.
 * @param params Any extra parameters you want passed in to the authentication request. This dictionary is parsed where each key value pair becomes "&key=value". We do not encode the URL after this, so any encoding will need to be done by the creator. This is a good place to put scope, for example: @{@"scope" : @"gist,repo"}
 */
- (id)initForService:(NSString *)service appID:(NSString *)appID apiKey:(NSString *)apiKey user:(CMUser *)user params:(NSDictionary *)params;

@end

