//
//  SocialLoginViewController.m
//  cloudmine-ios
//
//  Created by Nikko Schaff on 11/12/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "UIViewController+Modal.h"
#import "SocialLoginViewController.h"

@interface SocialLoginViewController ()
{
    NSMutableData* responseData;
    UIView* pendingLoginView;
    UIActivityIndicatorView* activityView;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UINavigationBar *navigationBar;

- (void)processAccessTokenWithData:(NSData*)data;

@end

@implementation SocialLoginViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        [self initializeView];
    }
    return self;
}

- (id)initForService:(NSString *)service withAppID:(NSString *)appID andApiKey:(NSString *)apiKey
{
    self = [super init];
    if (self)
    {
        [self initializeView];
        _targetService = service;
        _appID = appID;
        _apiKey = apiKey;
        _challenge = [[NSUUID UUID] UUIDString];

    }
    return self;
}

- (void)awakeFromNib
{
    [self initializeView];
}

- (void)initializeView
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [self presentViewController:self animated:YES completion:NULL];
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
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.cloudmine.me/v1/app/%@/account/social/login?service=%@&apikey=%@&challenge=%@",
                             _appID,_targetService,_apiKey,_challenge];
    NSLog(@"Going to auth url %@", urlStr);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}


-(void)processAccessTokenWithData:(NSData*)data;
{
    
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    // TODO work on this
    //if ([request.URL.scheme isEqualToString:[NSString stringWithFormat:@"fb%@", self.session.clientID]] && [request.URL.host isEqualToString:@"authorize"]) {
    
        
        pendingLoginView = [[UIView alloc] initWithFrame:self.view.bounds];
        pendingLoginView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(140, 180, activityView.bounds.size.width, activityView.bounds.size.height);
        [pendingLoginView addSubview:activityView];
        [activityView startAnimating];
        
        [self.view addSubview:pendingLoginView];
        [self.view bringSubviewToFront:pendingLoginView];
        
        NSLog(@"Getting the tokens");
        NSString* accessTokenStr = [NSString stringWithFormat:@"https://api.cloudmine.me/v1/app/%@/account/social/login/status?challenge=%@", _appID,_challenge];
        NSURL* accessTokenURL = [NSURL URLWithString:accessTokenStr];
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:accessTokenURL];
        req.HTTPMethod = @"GET";
        responseData = [NSMutableData data];
        [NSURLConnection connectionWithRequest:req delegate:self];
        NSLog(@"Request the token");
        return NO;
    //}
    //return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    
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
        if (self.delegate) {
            [self errorLoggingInToService:self.targetService withError:error];
        }
        return;
    }
    
    NSString* loginError = [jsonResult objectForKey:@"error"];
    if (loginError) {
        if (self.delegate) {
            NSError* error = [NSError errorWithDomain:@"socialSDK" code:100 userInfo:[NSDictionary dictionaryWithObject:loginError forKey:NSLocalizedDescriptionKey]];
            [self errorLoggingInToService:self.targetService withError:error];
            
        }
        return;
    }
    
    // TODO save information properly
    // Save the access token and account id
    _session_token = [jsonResult objectForKey:@"session_token"];
    //self.session.accountID = [jsonResult objectForKey:@"account"];
    
    //NSLog(@"All set to do requests as account %@ with session_token %@", self.session.accountID, self.session.accessToken);
    NSLog(@"JSON Response: %@", [jsonResult description]);
    if (self.delegate) {
        // TODO put info in callback response
        
        [self.delegate socialLoginViewController:self didLoginForService:self.targetService];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.delegate) {
        [self errorLoggingInToService:self.targetService withError:error];
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
