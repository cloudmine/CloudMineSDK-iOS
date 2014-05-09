
//
//  SocialLoginViewController.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//  Using some code of Stephane Copin, created on 3/28/14.
//

#import "CMSocialLoginViewController.h"
#import "CMWebService.h"
#import "CMStore.h"
#import "CMUser.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kStatusBarHeight (IS_IPAD ? 0 : (IS_IOS7 ? 20 : 0) )
#define kNavigationBarHeight 44.0f

#define kWebViewTag 1
#define kNavigationBarViewTag 2

@interface CMSocialLoginViewController ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) UIView *pendingLoginView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UINavigationBar *presentedNavigationBar;
@property (nonatomic, strong) UINavigationItem *presentedNavigationItem;

@end

@implementation CMSocialLoginViewController

- (id)initForService:(NSString *)service appID:(NSString *)appID apiKey:(NSString *)apiKey user:(CMUser *)user params:(NSDictionary *)params;
{
    if ( (self = [super init]) ) {
        _user = user;
        _targetService = service;
        _appID = appID;
        _apiKey = apiKey;
        _params = params;
        _challenge = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.tag = kWebViewTag;
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    if ([self.appDelegate respondsToSelector:@selector(cmSocialViewDidLoad:)]) {
        [self.appDelegate cmSocialViewDidLoad:self];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    ///
    /// Clear the cookies from the cache, so websites won't remember if you have logged in before.
    ///
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([self isBeingPresented]) {
        
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f,
                                                                                           0.0f,
                                                                                           self.view.frame.size.width,
                                                                                           kNavigationBarHeight + kStatusBarHeight)];
        
        navigationBar.tag = kNavigationBarViewTag;
        [self.view addSubview:navigationBar];
        
        UINavigationItem * navigationItem = [[UINavigationItem alloc] initWithTitle:self.targetService];
        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(dismiss)];
        navigationBar.items = @[navigationItem];
        
        self.presentedNavigationBar = navigationBar;
        self.presentedNavigationItem = navigationItem;
        
        self.webView.frame = CGRectMake(0,
                                        navigationBar.frame.size.height,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height - navigationBar.frame.size.height);
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/app/%@/account/social/login?service=%@&apikey=%@&challenge=%@",
                        _baseURL, _appID, _targetService, _apiKey, _challenge];
    
    ///
    /// Link accounts if user is logged in. If you don't want the accounts linked, log out the user.
    ///
    if ( _user && _user.isLoggedIn)
        urlStr = [urlStr stringByAppendingFormat:@"&session_token=%@", _user.token];
    
    ///
    /// Add any additional params to the request
    ///
    if ( _params != nil && [_params count] > 0 ) {
        for (NSString *key in _params) {
            urlStr = [urlStr stringByAppendingFormat:@"&%@=%@", key, [_params valueForKey:key]];
        }
    }
    
#ifdef DEBUG
    NSLog(@"Webview Loading: %@", urlStr);
#endif
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    if ([self.appDelegate respondsToSelector:@selector(cmSocialWebViewDidStartLoad:)]) {
        [self.appDelegate cmSocialWebViewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    if ([self.appDelegate respondsToSelector:@selector(cmSocialWebViewDidFinishLoad:)]) {
        [self.appDelegate cmSocialWebViewDidFinishLoad:self];
    }
    
    NSString *currentURLstr = [[[webView request] URL] absoluteString];
    
    NSString *baseURLstr = [NSString stringWithFormat:@"%@/app/%@/account/social/login/complete", _baseURL, _appID];
    
    if (currentURLstr.length >= baseURLstr.length) {
        NSString *comparableRequestStr = [currentURLstr substringToIndex:baseURLstr.length];
        
        // If at the challenge complete URL, prepare and send GET request for session token info
        if ([baseURLstr isEqualToString:comparableRequestStr]) {
            
            BOOL shouldShow = YES;
            if ([self.appDelegate respondsToSelector:@selector(cmSocialWebViewShouldShowDefaultIndicator:)]) {
                shouldShow = [self.appDelegate cmSocialWebViewShouldShowDefaultIndicator:self];
            }
            
            if (shouldShow) {
                // Display pending login view during request/processing
                _pendingLoginView = [[UIView alloc] initWithFrame:self.webView.bounds];
                _pendingLoginView.center = self.webView.center;
                _pendingLoginView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
                _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                _activityView.frame = CGRectMake(_pendingLoginView.frame.size.width / 2,
                                                 _pendingLoginView.frame.size.height / 2,
                                                 _activityView.bounds.size.width,
                                                 _activityView.bounds.size.height);
                
                _activityView.center = self.webView.center;
                [_pendingLoginView addSubview:_activityView];
                [_activityView startAnimating];
                [self.view addSubview:_pendingLoginView];
                [self.view bringSubviewToFront:_pendingLoginView];
            }
            
            if ([self.delegate respondsToSelector:@selector(cmSocialLoginViewController:completeSocialLoginWithChallenge:)]) {
                [self.delegate cmSocialLoginViewController:self completeSocialLoginWithChallenge:_challenge];
            }
        }
    }
    /// Else, this is an internal page we don't care about
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    /**
     * Interesting enough, this method is called sometimes when authenticating with Facebook - but the page continuous to load, and
     * does so sucessfully. The user can actually login. Other time though, the request may fail and be an actual failure.
     *
     * Because we don't really know the nature of this error, nor can we assume, we need to call the delegate and inform them of the error.
     */
    NSLog(@"WebView error. This sometimes happens when the User is logging into a social network where cookies have been stored and is already logged in. %@", [error description]);
    
    if ([self.appDelegate respondsToSelector:@selector(cmSocial:webViewDidError:)]) {
        [self.appDelegate cmSocial:self webViewDidError:error];
    }
    
    if ([self.delegate respondsToSelector:@selector(cmSocialLoginViewController:hadError:)]) {
        [self.delegate cmSocialLoginViewController:self hadError:error];
    }
    
}

#pragma mark -

- (void)dismiss;
{
    /**
     * The User may dismiss the dialog, but we still need to inform the delegate.
     */
    if ([self.delegate respondsToSelector:@selector(cmSocialLoginViewControllerWasDismissed:)]) {
        [self.delegate cmSocialLoginViewControllerWasDismissed:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
    
    if([self isBeingDismissed]) {
        [self.presentedNavigationBar removeFromSuperview];
        self.presentedNavigationBar = nil;
    }
}

- (NSString *)title;
{
    if(self.presentedNavigationItem != nil) {
        return self.presentedNavigationItem.title;
    }
    
    return [super title];
}

- (void)setTitle:(NSString *)title;
{
    if(self.presentedNavigationItem != nil) {
        self.presentedNavigationItem.title = title;
    } else {
        [super setTitle:title];
    }
}

- (UINavigationItem *)navigationItem;
{
    if(self.presentedNavigationItem != nil) {
        return self.presentedNavigationItem;
    } else {
        return [super navigationItem];
    }
}



@end
