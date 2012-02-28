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
#import "CMUser.h"
#import "CMServerFunction.h"
#import "CMPagingDescriptor.h"
#import "NSURL+QueryParameterAdditions.h"

static __strong NSSet *_validHTTPVerbs = nil;

@interface CMWebService (Private)
- (NSURL *)constructTextUrlAtUserLevel:(BOOL)atUserLevel withKeys:(NSArray *)keys query:(NSString *)searchString pagingOptions:(CMPagingDescriptor *)paging withServerSideFunction:(CMServerFunction *)function;
- (NSURL *)constructBinaryUrlAtUserLevel:(BOOL)atUserLevel withKey:(NSString *)key;
- (NSURL *)constructDataUrlAtUserLevel:(BOOL)atUserLevel withKeys:(NSArray *)keys withServerSideFunction:(CMServerFunction *)function;
- (ASIHTTPRequest *)constructHTTPRequestWithVerb:(NSString *)verb URL:(NSURL *)url appSecret:(NSString *)appSecret binaryData:(BOOL)isForBinaryData user:(CMUser *)user;
- (void)executeRequest:(ASIHTTPRequest *)request successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (void)executeBinaryDataFetchRequest:(ASIHTTPRequest *)request successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler  errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (void)executeBinaryDataUploadRequest:(ASIHTTPRequest *)request successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (NSURL *)appendKeys:(NSArray *)keys serverSideFunction:(CMServerFunction *)function query:(NSString *)queryString pagingOptions:(CMPagingDescriptor *)paging toURL:(NSURL *)theUrl;
@end

@implementation CMWebService
@synthesize networkQueue;

#pragma mark - Service initialization

- (id)init {
    CMAPICredentials *credentials = [CMAPICredentials sharedInstance];
    NSAssert([credentials appSecret] && [credentials appIdentifier],
             @"You must configure CMAPICredentials before using this method. If you don't want to use CMAPICredentials, you must call [CMWebService initWithAppSecret:appIdentifier:] instead of this method.");
    return [self initWithAppSecret:[credentials appSecret] appIdentifier:[credentials appIdentifier]];
}

- (id)initWithAppSecret:(NSString *)appSecret appIdentifier:(NSString *)appIdentifier {
    NSParameterAssert(appSecret);
    NSParameterAssert(appIdentifier);
    
    if (!_validHTTPVerbs) {
        _validHTTPVerbs = [NSSet setWithObjects:@"GET", @"POST", @"PUT", @"DELETE", nil];
    }
    
    if (self = [super init]) {
        self.networkQueue = [ASINetworkQueue queue];
        _appSecret = appSecret;
        _appIdentifier = appIdentifier;
    }
    return self;
}

#pragma mark - GET requests for non-binary data

- (void)getValuesForKeys:(NSArray *)keys 
      serverSideFunction:(CMServerFunction *)function
           pagingOptions:(CMPagingDescriptor *)paging
                    user:(CMUser *)user
          successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler 
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"GET" 
                                                             URL:[self constructTextUrlAtUserLevel:(user != nil) 
                                                                                          withKeys:keys
                                                                                             query:nil
                                                                                     pagingOptions:paging
                                                                            withServerSideFunction:function]
                                                          appSecret:_appSecret
                                                      binaryData:NO
                                                            user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - Search requests (non-binary data only)

- (void)searchValuesFor:(NSString *)searchQuery
     serverSideFunction:(CMServerFunction *)function
          pagingOptions:(CMPagingDescriptor *)paging
                   user:(CMUser *)user
         successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler 
           errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"GET" 
                                                             URL:[self constructTextUrlAtUserLevel:(user != nil) 
                                                                                          withKeys:nil
                                                                                             query:searchQuery
                                                                                     pagingOptions:paging
                                                                            withServerSideFunction:function]
                                                          appSecret:_appSecret
                                                      binaryData:NO
                                                            user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - GET requests for binary data

- (void)getBinaryDataNamed:(NSString *)key
                      user:(CMUser *)user
            successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler 
              errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"GET" 
                                                             URL:[self constructBinaryUrlAtUserLevel:(user != nil)
                                                                                             withKey:key]
                                                          appSecret:_appSecret
                                                      binaryData:NO
                                                            user:user];
    [self executeBinaryDataFetchRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - POST (update) requests for non-binary data

- (void)updateValuesFromDictionary:(NSDictionary *)data
                serverSideFunction:(CMServerFunction *)function
                              user:(CMUser *)user 
                    successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
                      errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"POST" 
                                                             URL:[self constructTextUrlAtUserLevel:(user != nil)
                                                                                          withKeys:nil
                                                                                             query:nil
                                                                                     pagingOptions:nil
                                                                            withServerSideFunction:function]
                                                          appSecret:_appSecret
                                                      binaryData:NO
                                                            user:user];
    [request appendPostData:[[data yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - POST requests for binary data

- (void)uploadBinaryData:(NSData *)data
                   named:(NSString *)key
              ofMimeType:(NSString *)mimeType
                    user:(CMUser *)user
          successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler 
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"PUT" 
                                                             URL:[self constructBinaryUrlAtUserLevel:(user != nil)
                                                                                             withKey:key]
                                                          appSecret:_appSecret
                                                      binaryData:YES
                                                            user:user];
    if (mimeType && ![mimeType isEqualToString:@""]) {
        [request addRequestHeader:@"Content-Type" value:mimeType];
    }
    [request setPostBody:[data mutableCopy]];
    [self executeBinaryDataUploadRequest:request successHandler:successHandler errorHandler:errorHandler];
}

- (void)uploadFileAtPath:(NSString *)path
                   named:(NSString *)key
              ofMimeType:(NSString *)mimeType
                    user:(CMUser *)user
          successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler 
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"PUT" 
                                                             URL:[self constructBinaryUrlAtUserLevel:(user != nil)
                                                                                             withKey:key]
                                                          appSecret:_appSecret
                                                      binaryData:YES
                                                            user:user];
    if (mimeType && ![mimeType isEqualToString:@""]) {
        [request addRequestHeader:@"Content-Type" value:mimeType];
    }
    [request setShouldStreamPostDataFromDisk:YES];
    [request setPostBodyFilePath:path];
    [self executeBinaryDataUploadRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - PUT (replace) requests for non-binary data

- (void)setValuesFromDictionary:(NSDictionary *)data
             serverSideFunction:(CMServerFunction *)function
                           user:(CMUser *)user 
                 successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
                   errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"PUT" 
                                                             URL:[self constructTextUrlAtUserLevel:(user != nil) 
                                                                                          withKeys:nil
                                                                                             query:nil
                                                                                     pagingOptions:nil 
                                                                            withServerSideFunction:function]
                                                          appSecret:_appSecret
                                                      binaryData:NO
                                                            user:user];
    [request appendPostData:[[data yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - DELETE requests for data

- (void)deleteValuesForKeys:(NSArray *)keys
                       user:(CMUser *)user
             successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
               errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"DELETE" URL:[[self constructDataUrlAtUserLevel:(user != nil) 
                                                                                                        withKeys:keys
                                                                                          withServerSideFunction:nil]
                                                                                URLByAppendingQueryString:@"all=true"]
                                                          appSecret:_appSecret
                                                      binaryData:NO
                                                            user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma - Request queueing and execution

- (void)executeRequest:(ASIHTTPRequest *)request 
        successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler 
          errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {

    __unsafe_unretained ASIHTTPRequest *blockRequest = request; // Stop the retain cycle.

    [request setCompletionBlock:^{
        NSDictionary *results = [blockRequest.responseString yajl_JSON];

        if (blockRequest.responseStatusCode == 400 || blockRequest.responseStatusCode == 500) {
            NSString *message = [results objectForKey:@"error"];
            NSError *err = [NSError errorWithDomain:@"CloudMine"
                                               code:500
                                           userInfo:[NSDictionary dictionaryWithObject:message
                                                                                forKey:@"message"]];
            if (errorHandler != nil) {
                errorHandler(err);
            }
        } else {
            NSDictionary *successes = nil;
            NSDictionary *errors = nil;
            if (results) {
                successes = [results objectForKey:@"success"];
                if (!successes) {
                    successes = [NSDictionary dictionary];
                }

                errors = [results objectForKey:@"errors"];
                if (!errors) {
                    errors = [NSDictionary dictionary];
                }
            }
            if (successHandler != nil) {
                successHandler(successes, errors);
            }
        }
    }];
    
    [request setFailedBlock:^{
        errorHandler(blockRequest.error);
    }];
    
    [self.networkQueue addOperation:request];
    [self.networkQueue go]; 
}

- (void)executeBinaryDataFetchRequest:(ASIHTTPRequest *)request 
        successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler 
          errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    __unsafe_unretained ASIHTTPRequest *blockRequest = request; // Stop the retain cycle.
    
    [request setCompletionBlock:^{
        if (blockRequest.responseStatusCode == 200) {
            if (successHandler != nil) {
                successHandler(blockRequest.responseData, [blockRequest.responseHeaders objectForKey:@"Content-Type"]);
            }
        } else {
            if (errorHandler != nil) {
                NSError *err = [NSError errorWithDomain:@"CloudMine"
                                                   code:blockRequest.responseStatusCode
                                               userInfo:[NSDictionary dictionaryWithObject:blockRequest.responseStatusMessage forKey:@"message"]];
                errorHandler(err);
            }
        }
    }];
    
    [request setFailedBlock:^{
        if (errorHandler != nil) {
            errorHandler(blockRequest.error);
        }
    }];
    
    [self.networkQueue addOperation:request];
    [self.networkQueue go]; 
}

- (void)executeBinaryDataUploadRequest:(ASIHTTPRequest *)request 
                       successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler 
                         errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    __unsafe_unretained ASIHTTPRequest *blockRequest = request; // Stop the retain cycle.
    
    [request setCompletionBlock:^{
        if (successHandler != nil) {
            successHandler(blockRequest.responseStatusCode == 201 ? CMFileCreated : CMFileUpdated);
        }
    }];
    
    [request setFailedBlock:^{
        if (errorHandler != nil) {
            errorHandler(blockRequest.error);
        }
    }];
    
    [self.networkQueue addOperation:request];
    [self.networkQueue go]; 
}

#pragma - Request construction

- (ASIHTTPRequest *)constructHTTPRequestWithVerb:(NSString *)verb 
                                             URL:(NSURL *)url
                                          appSecret:(NSString *)appSecret
                                      binaryData:(BOOL)isForBinaryData
                                            user:(CMUser *)user {
    NSAssert([_validHTTPVerbs containsObject:verb], @"You must pass in a valid HTTP verb. Possible choices are: GET, POST, PUT, and DELETE");
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.requestMethod = verb;
    if (user) {
        request.username = user.userId;
        request.password = user.password;
        request.shouldPresentCredentialsBeforeChallenge = YES;
        request.authenticationScheme = (NSString *)kCFHTTPAuthenticationSchemeBasic;
    }
    [request addRequestHeader:@"X-CloudMine-ApiKey" value:appSecret];
    
    // TODO: This should be customizable to change between JSON, GZIP'd JSON, and MsgPack.
    
    // Don't do this for binary data since that requires further intervention by the developer.
    if (!isForBinaryData) {
        [request addRequestHeader:@"Content-type" value:@"application/json"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
    }
    return request;
}

#pragma mark - General URL construction

- (NSURL *)constructTextUrlAtUserLevel:(BOOL)atUserLevel
                              withKeys:(NSArray *)keys
                                 query:(NSString *)searchString
                         pagingOptions:(CMPagingDescriptor *)paging
                withServerSideFunction:(CMServerFunction *)function {
    
    NSAssert(keys == nil || searchString == nil, @"When constructing CM URLs, 'keys' and 'searchString' are mutually exclusive");
    
    NSString *endpoint = nil;
    if (searchString != nil) {
        endpoint = @"search";
    } else {
        endpoint = @"text";
    }
    
    NSURL *url;
    if (atUserLevel) {
        url = [NSURL URLWithString:[CM_BASE_URL stringByAppendingFormat:@"/app/%@/user/%@", _appIdentifier, endpoint]];
    } else {
        url = [NSURL URLWithString:[CM_BASE_URL stringByAppendingFormat:@"/app/%@/%@", _appIdentifier, endpoint]];
    }
    
    return [self appendKeys:keys serverSideFunction:function query:searchString pagingOptions:paging toURL:url];
}

- (NSURL *)constructBinaryUrlAtUserLevel:(BOOL)atUserLevel
                                withKey:(NSString *)key {
    NSURL *url;
    if (atUserLevel) {
        url = [NSURL URLWithString:[CM_BASE_URL stringByAppendingFormat:@"/app/%@/user/binary/%@", _appIdentifier, key]];
    } else {
        url = [NSURL URLWithString:[CM_BASE_URL stringByAppendingFormat:@"/app/%@/binary/%@", _appIdentifier, key]];
    }
    
    return url;
}

- (NSURL *)constructDataUrlAtUserLevel:(BOOL)atUserLevel
                              withKeys:(NSArray *)keys
                withServerSideFunction:(CMServerFunction *)function {
    NSURL *url;
    if (atUserLevel) {
        url = [NSURL URLWithString:[CM_BASE_URL stringByAppendingFormat:@"/app/%@/user/data", _appIdentifier]];
    } else {
        url = [NSURL URLWithString:[CM_BASE_URL stringByAppendingFormat:@"/app/%@/data", _appIdentifier]];
    }
    
    return [self appendKeys:keys serverSideFunction:function query:nil pagingOptions:nil toURL:url];
}

- (NSURL *)appendKeys:(NSArray *)keys 
   serverSideFunction:(CMServerFunction *)function
                query:(NSString *)searchString
        pagingOptions:(CMPagingDescriptor *)paging
                toURL:(NSURL *)theUrl {
    
    NSAssert(keys == nil || searchString == nil, @"When constructing CM URLs, 'keys' and 'searchString' are mutually exclusive");
    
    NSMutableArray *queryComponents = [NSMutableArray arrayWithCapacity:2];
    if (keys && [keys count] > 0) {
        [queryComponents addObject:[NSString stringWithFormat:@"keys=%@", [keys componentsJoinedByString:@","]]];
    }
    if (function) {
        [queryComponents addObject:[function stringRepresentation]];
    }
    if (searchString) {
        [queryComponents addObject:[NSString stringWithFormat:@"q=%@", searchString]];
    }
    if (paging) {
        [queryComponents addObject:[paging stringRepresentation]];
    }
    return [theUrl URLByAppendingQueryString:[queryComponents componentsJoinedByString:@"&"]];
}

@end
