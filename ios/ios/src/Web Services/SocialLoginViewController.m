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

- (id)initForService:(NSString *)service
{
    self = [super init];
    if (self)
    {
        [self initializeView];
        _targetService = service;
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated;
{
    // TODO work on this
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
    
    NSString* urlStr = [NSString stringWithFormat:@"https://api.social.com/oauth/authorize?redirect_uri=fb%@://authorize&service=%@&client_id=%@", self.session.clientID, self.targetService, self.session.clientID];
    if (self.session.accountID) {
        urlStr = [urlStr stringByAppendingFormat:@"&account=%@", self.session.accountID];
    } else {
        urlStr = [urlStr stringByAppendingString:@"&account=false"];
    }
    if (self.scope) {
        urlStr = [urlStr stringByAppendingFormat:@"&scope=%@", self.scope];
    }
    if (self.flags) {
        urlStr = [urlStr stringByAppendingFormat:@"&flag=%@", self.flags];
    }
    NSLog(@"Going to auth url %@", urlStr);
    // TODO setup
    NSString *loginURLstr = [NSString stringWithFormat:@"http://api.cloudmine.me/v1/app/%@/account/social/login?service=%@&apikey=%@&challenge=%@",
                             appID,service,apiKey,_challenge];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}


-(void)processAccessTokenWithData:(NSData*)data;
{
    
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    // TODO work on this
    if ([request.URL.scheme isEqualToString:[NSString stringWithFormat:@"fb%@", self.session.clientID]] && [request.URL.host isEqualToString:@"authorize"]) {
        
        pendingLoginView = [[UIView alloc] initWithFrame:self.view.bounds];
        pendingLoginView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(140, 180, activityView.bounds.size.width, activityView.bounds.size.height);
        [pendingLoginView addSubview:activityView];
        [activityView startAnimating];
        
        [self.view addSubview:pendingLoginView];
        [self.view bringSubviewToFront:pendingLoginView];
        
        // Find the code and request an access token
        NSArray *parameterPairs = [request.URL.query componentsSeparatedByString:@"&"];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[parameterPairs count]];
        
        for (NSString *currentPair in parameterPairs) {
            NSArray *pairComponents = [currentPair componentsSeparatedByString:@"="];
            
            NSString *key = ([pairComponents count] >= 1 ? [pairComponents objectAtIndex:0] : nil);
            if (key == nil) continue;
            
            NSString *value = ([pairComponents count] >= 2 ? [pairComponents objectAtIndex:1] : [NSNull null]);
            [parameters setObject:value forKey:key];
        }
        
        if ([parameters objectForKey:@"code"]) {
            NSLog(@"Getting the tokens");
            NSURL* accessTokenURL = [NSURL URLWithString:@"https://api.social.com/oauth/access_token"];
            NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:accessTokenURL];
            req.HTTPMethod = @"POST";
            req.HTTPBody = [[NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", self.session.clientID, self.session.clientSecret, [parameters objectForKey:@"code"]] dataUsingEncoding:NSUTF8StringEncoding];
            responseData = [NSMutableData data];
            [NSURLConnection connectionWithRequest:req delegate:self];
        }
        NSLog(@"Request the token");
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    //TODO:  Fill this in
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
    // TODO work on this
    
    NSError *error;
    NSDictionary* jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if (error) {
        if (self.delegate) {
            [self.delegate socialLoginViewController:self errorLoggingInToService:self.targetService withError:error];
        }
        return;
    }
    
    NSString* loginError = [jsonResult objectForKey:@"error"];
    if (loginError) {
        if (self.delegate) {
            NSError* error = [NSError errorWithDomain:@"socialSDK" code:100 userInfo:[NSDictionary dictionaryWithObject:loginError forKey:NSLocalizedDescriptionKey]];
            [self.delegate socialLoginViewController:self errorLoggingInToService:self.targetService withError:error];
            
        }
        return;
    }
    
    // Save the access token and account id
    self.session.accessToken = [jsonResult objectForKey:@"access_token"];
    self.session.accountID = [jsonResult objectForKey:@"account"];
    [self.session updateProfilesWithCompletion:^{
        NSLog(@"All set to do requests as account %@ with access token %@", self.session.accountID, self.session.accessToken);
        if (self.delegate) {
            [self.delegate socialLoginViewController:self didLoginForService:self.targetService];
        }
    }];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.delegate) {
        [self.delegate socialLoginViewController:self errorLoggingInToService:self.targetService withError:error];
    }
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
