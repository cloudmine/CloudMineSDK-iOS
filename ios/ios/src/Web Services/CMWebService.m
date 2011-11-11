//
//  CMWebService.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#import "CMWebService.h"
#import "CMAPICredentials.h"
#import "CMUserCredentials.h"
#import "NSURL+QueryParameterAdditions.h"

static __strong NSSet *_validHTTPVerbs = nil;

@interface CMWebService (Private)
- (NSURL *)constructTextUrlAtUserLevel:(BOOL)atUserLevel withKeys:(NSArray *)keys;
- (ASIHTTPRequest *)constructHTTPRequestWithVerb:(NSString *)verb URL:(NSURL *)url userCredentials:(CMUserCredentials *)userCredentials;
- (void)executeRequest:(ASIHTTPRequest *)request successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
          errorHandler:(void (^)(NSError *error))errorHandler;
@end

@implementation CMWebService
@synthesize networkQueue;

#pragma mark - Service initialization

- (id)init {
    CMAPICredentials *credentials = [CMAPICredentials sharedInstance];
    NSAssert([credentials apiKey] && [credentials appKey],
             @"You must configure CMAPICredentials before using this method. If you don't want to use CMAPICredentials, you must call [CMWebService initWithAPIKey:appKey:] instead of this method.");
    return [self initWithAPIKey:[credentials apiKey] appKey:[credentials appKey]];
}

- (id)initWithAPIKey:(NSString *)apiKey appKey:(NSString *)appKey {
    NSParameterAssert(apiKey);
    NSParameterAssert(appKey);
    
    if (!_validHTTPVerbs) {
        _validHTTPVerbs = [NSSet setWithObjects:@"GET", @"POST", @"PUT", @"DELETE", nil];
    }
    
    if (self = [super init]) {
        self.networkQueue = [ASINetworkQueue queue];
        _apiKey = apiKey;
        _appKey = appKey;
    }
    return self;
}

#pragma mark - GET requests for non-binary data

- (void)getValuesForKeys:(NSArray *)keys successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
            errorHandler:(void (^)(NSError *error))errorHandler {
    
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"GET" URL:[self constructTextUrlAtUserLevel:NO withKeys:keys]
                                                 userCredentials:nil];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

- (void)getValuesForKeys:(NSArray *)keys withUserCredentials:(CMUserCredentials *)credentials successHandler:(void (^)(NSArray *objects))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler {
    
}

#pragma - Request queueing and execution

- (void)executeRequest:(ASIHTTPRequest *)request successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
          errorHandler:(void (^)(NSError *error))errorHandler {
    
    __unsafe_unretained ASIHTTPRequest *blockRequest = request; // Stop the retain cycle.
    
    [request setCompletionBlock:^{
        NSDictionary *results = [blockRequest.responseString yajl_JSON];
        successHandler([results objectForKey:@"success"], [results objectForKey:@"errors"]);
    }];
    
    [request setFailedBlock:^{
        errorHandler(blockRequest.error);
    }];
    
    [self.networkQueue addOperation:request];
}

#pragma - Request construction

- (ASIHTTPRequest *)constructHTTPRequestWithVerb:(NSString *)verb URL:(NSURL *)url userCredentials:(CMUserCredentials *)userCredentials {
    NSAssert([_validHTTPVerbs containsObject:verb], @"You must pass in a valid HTTP verb. Possible choices are: GET, POST, PUT, and DELETE");
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.requestMethod = verb;
    if (userCredentials) {
        request.username = userCredentials.userId;
        request.password = userCredentials.password;
    }
    return request;
}

#pragma mark - General URL construction

- (NSURL *)constructTextUrlAtUserLevel:(BOOL)atUserLevel withKeys:(NSArray *)keys {
    NSURL *url;
    if (atUserLevel) {
        url = [NSURL URLWithString:[CM_BASE_URL stringByAppendingFormat:@"/app/%@/user/text", _appKey]];
    } else {
        url = [NSURL URLWithString:[CM_BASE_URL stringByAppendingFormat:@"/app/%@/text", _appKey]];
    }
    
    return [url URLByAppendingQueryString:[NSString stringWithFormat:@"keys=%@", [keys componentsJoinedByString:@","]]];
}

@end
