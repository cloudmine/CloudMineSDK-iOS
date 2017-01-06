//
//  SocialLoginViewController.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <UIKit/UIKit.h>

@class CMSocialLoginViewController;
@class CMUser;

/**
 * Protocol which allows for the app to know when certain events are happening
 * inside the login controller.
 */
@protocol CMSocialWebViewDelegate <NSObject>
@optional

/**
 * Called when the viewDidLoad.
 * @param controller The CMSocialLoginViewController that is being presented.
 */
- (void)cmSocialViewDidLoad:(nonnull CMSocialLoginViewController *)controller;

/**
 * Called when the webView calls webViewDidStartLoad.
 * @param controller The CMSocialLoginViewController that is being presented.
 */
- (void)cmSocialWebViewDidStartLoad:(nonnull CMSocialLoginViewController *)controller;

/**
 * Called when the webView calls didFailLoadWithError. Implementing this method will not override any default behavior.
 * Note that implementing this method will have no impact on whether CMUserAccountSocialLoginErrorOccurred is sent to
 * the login callback.
 * @param controller The CMSocialLoginViewController that is being presented.
 */
- (void)cmSocial:(nonnull CMSocialLoginViewController *)controller webViewDidError:(nullable NSError *)error;

/**
 * Called when the WebView Did finish loading. Implementing this will not stop the authentication process, but you can
 * use it as a hook to perform your own custom UI work.
 * @param controller The CMSocialLoginViewController that is being presented.
 */
- (void)cmSocialWebViewDidFinishLoad:(nonnull CMSocialLoginViewController *)controller;

/**
 * Return NO if you do not want the default indicator shown after the user attempts to login. Return YES or
 * do not implement this method if you want it shown.
 * @param controller The CMSocialLoginViewController that is being presented.
 * @return bool No if you do not want the default to show. YES otherwise.
 */
- (BOOL)cmSocialWebViewShouldShowDefaultIndicator:(nonnull CMSocialLoginViewController *)controller;

@end


/**
 * The Protocol which defines the method required for working with Social Login.
 *
 */
@protocol CMSocialLoginViewControllerDelegate <NSObject>

@optional
/**
 * Optional Method for when the login completes in the webview.
 *
 * @param controller The CMSocialLoginViewController object which completed the request.
 * @param challenge The challenge which was used in the request.
 *
 */
- (void)cmSocialLoginViewController:(nonnull CMSocialLoginViewController *)controller completeSocialLoginWithChallenge:(nullable NSString *)challenge;

/**
 * Optional method for handling when the WebView gets an error.
 *
 * @param controller The CMSocialLoginViewController object which completed the request.
 * @param error The NSError which the WebView received.
 */
- (void)cmSocialLoginViewController:(nonnull CMSocialLoginViewController *)controller hadError:(nullable NSError *)error;

/**
 * The Optional method for handling when the user taps the Dismiss button on the modal popup.
 *
 * @param controller The CMSocialLoginViewController object which completed the request.
 */
- (void)cmSocialLoginViewControllerWasDismissed:(nonnull CMSocialLoginViewController *)controller;
@end

/**
 * The UIViewController which is presented to the user and manages the OAuth call.
 */
@interface CMSocialLoginViewController : UIViewController <UIWebViewDelegate>

/**
 * The CMSocialLoginViewControllerDelegate delegates which is used in the callbacks.
 */
@property (nonatomic, weak, nullable) id<CMSocialLoginViewControllerDelegate> delegate;

/**
 * The delegate that can be set by the Application to be used for customization.
 */
@property (nonatomic, weak, nullable) id<CMSocialWebViewDelegate> appDelegate;

/**
 * The Social Service which is being logged into, such as "facebook" or "twitter".
 */
@property (nonatomic, copy, nullable) NSString *targetService;

/**
 * The App ID for the CloudMine App.
 */
@property (nonatomic, copy, nullable) NSString *appID;

/**
 * The App Secret for the CloudMine App.
 */
@property (nonatomic, copy, nullable) NSString *apiKey;

/**
 * The Challenge used in the request.
 */
@property (nonatomic, copy, nullable) NSString *challenge;

/**
 * An optional dictionary of parameters to pass in with the URL.
 */
@property (nonatomic, copy, nullable) NSDictionary *params;

/**
 * A CMUser to associate to this social login account.
 */
@property (nonatomic, nullable) CMUser *user;

/**
 * The base URL in which to send th request. This is important because you could be
 * working with one of many stacks.
 */
@property (nonatomic, copy, nullable) NSString *baseURL;

/**
 * WebView is public for customization. Be careful when modifying this as to not
 * break social login.
 */
@property (nonatomic, nullable) UIWebView *webView;

/**
 *
 * Initialize with a service identifier
 *
 * @param service The name of the service that we are logging into
 * @param appID The appID gotten from the dashboard
 * @param apiKey The APIKey from the dashboard for your application
 * @param user Can be nil, the user you want to link accounts with. If this parameter is nil, we will not link the accounts. If you pass in the user, we will attempt to link the accounts.
 * @param params Any extra parameters you want passed in to the authentication request. This dictionary is parsed where each key value pair becomes "&key=value". We do not encode the URL after this, so any encoding will need to be done by the creator. This is a good place to put scope, for example: @{@"scope" : @"gist,repo"}
 * @return The CMSocialLoginViewController object.
 */
- (nonnull instancetype)initForService:(nonnull NSString *)service appID:(nonnull NSString *)appID apiKey:(nonnull NSString *)apiKey user:(nullable CMUser *)user params:(nullable NSDictionary *)params;

@end

