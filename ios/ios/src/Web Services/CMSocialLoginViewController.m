//
//  SocialLoginViewController.m
//  cloudmine-ios
//
//  Created by Nikko Schaff on 11/12/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMUIViewController+Modal.h"
#import "CMSocialLoginViewController.h"

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
    
    NSString *urlStr = [NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/social/login?service=%@&apikey=%@&challenge=%@",
                             _appID,_targetService,_apiKey,_challenge];
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
    NSURLRequest *currentRequest = [webView request];
    NSURL *currentURL = [currentRequest URL];
    NSString *currentURLstr = [currentURL absoluteString];
    
    NSString *baseURLstr = [NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/social/login/complete", _appID];
    
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
        
            // Request the session token info
            NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:
                                         [NSString stringWithFormat:
                                          @"https://api.cloudmine.me/v1/app/%@/account/social/login/status?challenge=%@",_appID,_challenge]]];
            req.HTTPMethod = @"GET";
            responseData = [NSMutableData data];
            [req setValue:self.apiKey forHTTPHeaderField:@"X-CloudMine-ApiKey"];
            NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:req delegate:self];
            if (connection) {
                responseData = [NSMutableData data];
                [data 
            }
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    //TODO:  Fill this in (comment leftover from Singly sdk)
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
    NSError *error;
    NSDictionary* jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"JSON error with Response: %@", [jsonResult description]);
        if (self.delegate) {
            [self errorLoggingInToService:self.targetService withError:error];
        }
        return;
    }
    
    NSString* loginError = [jsonResult objectForKey:@"error"];
    if (loginError) {
        NSLog(@"Login error");
        if (self.delegate) {
            NSError* error = [NSError errorWithDomain:@"socialSDK" code:100 userInfo:[NSDictionary dictionaryWithObject:loginError forKey:NSLocalizedDescriptionKey]];
            [self errorLoggingInToService:self.targetService withError:error];
        }
        return;
    }
    
    NSLog(@"We ready to JSON now");
    
    // TODO save information properly
    // Save the access token and account id
    _session_token = [jsonResult objectForKey:@"session_token"];
    //self.session.accountID = [jsonResult objectForKey:@"account"];
    
    //NSLog(@"All set to do requests as account %@ with session_token %@", self.session.accountID, self.session.accessToken);
    NSLog(@"JSON Response: %@", [jsonResult description]);
    if (self.delegate) {
        // TODO put info in callback response
        [self.delegate cmSocialLoginViewController:self didLoginForService:self.targetService];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.delegate) {
        [self.delegate cmSocialLoginViewController:self errorLoggingInToService:self.targetService withError:error];
    }
}


-(void)errorLoggingInToService:(NSString *)service withError:(NSError *)error
{
    // TODO handle errors with callback response info, not alert
    
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
