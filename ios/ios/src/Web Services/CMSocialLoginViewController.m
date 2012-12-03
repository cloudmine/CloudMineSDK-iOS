//
//  SocialLoginViewController.m
//  cloudmine-ios
//
//  Created by Nikko Schaff on 11/12/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMUIViewController+Modal.h"
#import "CMSocialLoginViewController.h"
#import "CMWebService.h"
#import "CMStore.h"

@interface CMSocialLoginViewController ()
{
    NSMutableData* responseData;
    UIView* pendingLoginView;
    UIActivityIndicatorView* activityView;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UINavigationBar *navigationBar;

- (void)processAccessTokenWithData:(NSData*)data;

@end

@implementation CMSocialLoginViewController

- (id)initForService:(NSString *)service withAppID:(NSString *)appID andApiKey:(NSString *)apiKey
{
    self = [super init];
    if (self)
    {
        _targetService = service;
        _appID = appID;
        _apiKey = apiKey;
        _challenge = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated;
{
    if (self.isModal)
    {
        self.webView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44);
        self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:self.targetService];
        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
        self.navigationBar.items = @[navigationItem];
        
        //
        // Set the tint color of our navigation bar to match the tint of the
        // view controller's navigation bar that is responsible for presenting
        // us modally.
        //
        if ([self.presentingViewController respondsToSelector:@selector(navigationBar)])
        {
            UIColor *presentingTintColor = ((UINavigationController *)self.presentingViewController).navigationBar.tintColor;
            self.navigationBar.tintColor = presentingTintColor;
        }
        [self.view addSubview:self.navigationBar];
    }
    else
    {
        if (self.navigationBar)
        {
            [self.navigationBar removeFromSuperview];
            self.navigationBar = nil;
        }
    }
    
    NSString *urlStr = nil;
    
    // Check to see if user is signed in already, if so, link accounts.
    // Check more than default store?
    if ([[CMStore defaultStore] user] && [[CMStore defaultStore] user].isLoggedIn) {
        urlStr = [NSString stringWithFormat:@"%@/app/%@/account/social/login?service=%@&apikey=%@&challenge=%@&session_token=%@",
                  CM_BASE_URL, _appID, _targetService, _apiKey, _challenge, [[CMStore defaultStore] user].token ];
    } else {
        urlStr = [NSString stringWithFormat:@"%@/app/%@/account/social/login?service=%@&apikey=%@&challenge=%@",
                    CM_BASE_URL, _appID, _targetService, _apiKey, _challenge];
    }
    
     
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}


-(void)processAccessTokenWithData:(NSData*)data;
{
    
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    
    NSString *currentURLstr = [[[webView request] URL] absoluteString];
        
    NSString *baseURLstr = [NSString stringWithFormat:@"%@/app/%@/account/social/login/complete", CM_BASE_URL, _appID];
    
    if (currentURLstr.length >= baseURLstr.length) {
        NSString *comparableRequestStr = [currentURLstr substringToIndex:baseURLstr.length];

        // If at the challenge complete URL, prepare and send GET request for session token info
        if ([baseURLstr isEqualToString:comparableRequestStr]) {
        
            // Display pending login view during request/processing
            pendingLoginView = [[UIView alloc] initWithFrame:self.view.bounds];
            pendingLoginView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityView.frame = CGRectMake(140, 180, activityView.bounds.size.width, activityView.bounds.size.height);
            [pendingLoginView addSubview:activityView];
            [activityView startAnimating];
            [self.view addSubview:pendingLoginView];
            [self.view bringSubviewToFront:pendingLoginView];
            
            // Call WebService function to establish GET for session token and user profile
            [self.delegate cmSocialLoginViewController:self completeSocialLoginWithChallenge:_challenge];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    //TODO:  Fill this in (comment leftover from Singly sdk)
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
