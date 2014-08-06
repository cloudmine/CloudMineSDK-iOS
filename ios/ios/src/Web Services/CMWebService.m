//
//  CMWebService.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <AFNetworking/AFNetworking.h>

#import "CMWebService.h"
#import "CMStore.h"
#import "CMAPICredentials.h"
#import "CMUser.h"
#import "CMServerFunction.h"
#import "CMPagingDescriptor.h"
#import "CMSortDescriptor.h"
#import "CMActiveUser.h"
#import "NSURL+QueryParameterAdditions.h"
#import "NSDictionary+CMJSON.h"
#import "CMConstants.h"
#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"
#import "CMObjectSerialization.h"
#import "CMSocialAccountChooser.h"
#import "CMUserResponse.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@class FBSession;

#define CM_APIKEY_HEADER @"X-CloudMine-ApiKey"
#define CM_SESSIONTOKEN_HEADER @"X-CloudMine-SessionToken"

static __strong NSSet *_validHTTPVerbs = nil;
typedef CMUserAccountResult (^_CMWebServiceAccountResponseCodeMapper)(NSUInteger httpResponseCode, NSError *error);

NSString * const CMErrorDomain = @"CMErrorDomain";
NSString * const NSURLErrorKey = @"NSURLErrorKey";
NSString * const JSONErrorKey = @"JSONErrorKey";

@interface CMWebService () {
    NSMutableDictionary *_responseTimes;
    __strong CMWebServiceUserAccountOperationCallback temporaryCallback;
}

@property (nonatomic, copy) NSString *apiUrl;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) CMSocialAccountChooser *picker;

- (NSURL *)constructTextUrlAtUserLevel:(BOOL)atUserLevel withKeys:(NSArray *)keys query:(NSString *)searchString pagingOptions:(CMPagingDescriptor *)paging sortingOptions:(CMSortDescriptor *)sorting withServerSideFunction:(CMServerFunction *)function extraParameters:(NSDictionary *)params;
- (NSURL *)constructBinaryUrlAtUserLevel:(BOOL)atUserLevel withKey:(NSString *)key withServerSideFunction:(CMServerFunction *)function extraParameters:(NSDictionary *)params;
- (NSURL *)constructDataUrlAtUserLevel:(BOOL)atUserLevel withKeys:(NSArray *)keys withServerSideFunction:(CMServerFunction *)function extraParameters:(NSDictionary *)params;
- (NSMutableURLRequest *)constructHTTPRequestWithVerb:(NSString *)verb URL:(NSURL *)url appSecret:(NSString *)appSecret binaryData:(BOOL)isForBinaryData user:(CMUser *)user;
- (void)executeUserAccountActionRequest:(NSURLRequest *)request codeMapper:(_CMWebServiceAccountResponseCodeMapper)codeMapper callback:(CMWebServiceUserAccountOperationCallback)callback;
- (void)executeRequest:(NSURLRequest *)request successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (void)executeBinaryDataFetchRequest:(NSURLRequest *)request successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler  errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (void)executeBinaryDataUploadRequest:(NSURLRequest *)request successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (NSURL *)constructAccountUrlWithUserIdentifier:(NSString *)userId query:(NSString *)query;
- (NSURL *)appendKeys:(NSArray *)keys query:(NSString *)queryString serverSideFunction:(CMServerFunction *)function pagingOptions:(CMPagingDescriptor *)paging sortingOptions:(CMSortDescriptor *)sorting toURL:(NSURL *)theUrl extraParameters:(NSDictionary *)params;
- (void)_subscribeDevice:(NSString *)deviceID orUser:(CMUser *)user toPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback;
- (void)_unSubscribeDevice:(NSString *)deviceID orUser:(CMUser *)user fromPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback;
@end


@implementation CMWebService

#pragma mark - Service initialization

+ (CMWebService *)sharedWebService {
    static CMWebService *_sharedWebService;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWebService = [[CMWebService alloc] init];
    });
    
    return _sharedWebService;
}

- (id)init;
{
    CMAPICredentials *credentials = [CMAPICredentials sharedInstance];
    NSAssert([credentials appSecret] && [credentials appIdentifier],
             @"You must configure CMAPICredentials before using this method. If you don't want to use CMAPICredentials, you must call [CMWebService initWithAppSecret:appIdentifier:] instead of this method.");
    return [self initWithAppSecret:[credentials appSecret] appIdentifier:[credentials appIdentifier]];
}

- (id)initWithBaseURL:(NSURL *)url;
{
    CMAPICredentials *credentials = [CMAPICredentials sharedInstance];
    if (!url) {
        url = [NSURL URLWithString:credentials.baseURL];
    }
    
    NSAssert([credentials appSecret] && [credentials appIdentifier],
             @"You must configure CMAPICredentials before using this method. If you don't want to use CMAPICredentials, you must call [CMWebService initWithAppSecret:appIdentifier:] instead of this method.");
    
    return [self initWithAppSecret:credentials.appSecret appIdentifier:credentials.appIdentifier baseURL:url];
}

- (id)initWithAppSecret:(NSString *)appSecret appIdentifier:(NSString *)appIdentifier;
{
    CMAPICredentials *credentials = [CMAPICredentials sharedInstance];
    return [self initWithAppSecret:appSecret appIdentifier:appIdentifier baseURL:[NSURL URLWithString:credentials.baseURL]];
}

- (id)initWithAppSecret:(NSString *)appSecret appIdentifier:(NSString *)appIdentifier baseURL:(NSURL *)url;
{
    NSParameterAssert(appSecret);
    NSParameterAssert(appIdentifier);
    NSParameterAssert(url);
    
    if (!_validHTTPVerbs) {
        _validHTTPVerbs = [NSSet setWithObjects:@"GET", @"POST", @"PUT", @"DELETE", @"PATCH", nil];
    }
    
    if ((self = [super initWithBaseURL:url])) {
        self.apiUrl = url.absoluteString;
        
        _appSecret = appSecret;
        _appIdentifier = appIdentifier;
        _responseTimes = [NSMutableDictionary dictionary];
        
        // Enable activity indicator in status bar
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    return self;
}

- (void)setApiUrl:(NSString *)apiUrl;
{
    if (![apiUrl hasSuffix:@"/"]) {
        apiUrl = [apiUrl stringByAppendingString:@"/"];
    }
    _apiUrl = [apiUrl stringByAppendingString:CM_DEFAULT_API_VERSION];
}

#pragma mark - GET requests for non-binary data

- (void)getValuesForKeys:(NSArray *)keys
      serverSideFunction:(CMServerFunction *)function
           pagingOptions:(CMPagingDescriptor *)paging
          sortingOptions:(CMSortDescriptor *)sorting
                    user:(CMUser *)user
         extraParameters:(NSDictionary *)params
          successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSURLRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                           URL:[self constructTextUrlAtUserLevel:(user != nil)
                                                                                        withKeys:keys
                                                                                           query:nil
                                                                                   pagingOptions:paging
                                                                                  sortingOptions:sorting
                                                                          withServerSideFunction:function
                                                                                 extraParameters:params]
                                                     appSecret:_appSecret
                                                    binaryData:NO
                                                          user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

- (void)getACLsForUser:(CMUser *)user
        successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
          errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSURLRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                           URL:[self constructACLUrlWithKey:nil query:nil extraParameters:nil]
                                                     appSecret:_appSecret
                                                    binaryData:NO
                                                          user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - Search requests (non-binary data only)

- (void)searchValuesFor:(NSString *)searchQuery
     serverSideFunction:(CMServerFunction *)function
          pagingOptions:(CMPagingDescriptor *)paging
         sortingOptions:(CMSortDescriptor *)sorting
                   user:(CMUser *)user
        extraParameters:(NSDictionary *)params
         successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
           errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSURLRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                           URL:[self constructTextUrlAtUserLevel:(user != nil)
                                                                                        withKeys:nil
                                                                                           query:searchQuery
                                                                                   pagingOptions:paging
                                                                                  sortingOptions:sorting
                                                                          withServerSideFunction:function
                                                                                 extraParameters:params]
                                                     appSecret:_appSecret
                                                    binaryData:NO
                                                          user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

- (void)searchACLs:(NSString *)query
              user:(CMUser *)user
    successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
      errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    NSURLRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                           URL:[self constructACLUrlWithKey:nil query:query extraParameters:nil]
                                                     appSecret:_appSecret
                                                    binaryData:NO
                                                          user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - GET requests for binary data

- (void)getBinaryDataNamed:(NSString *)key
        serverSideFunction:(CMServerFunction *)function
                      user:(CMUser *)user
           extraParameters:(NSDictionary *)params
            successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler
              errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSURLRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                           URL:[self constructBinaryUrlAtUserLevel:(user != nil)
                                                                                           withKey:key
                                                                            withServerSideFunction:function
                                                                                   extraParameters:params]
                                                     appSecret:_appSecret
                                                    binaryData:NO
                                                          user:user];
    [self executeBinaryDataFetchRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - POST (update) requests for non-binary data

- (void)updateValuesFromDictionary:(NSDictionary *)data
                serverSideFunction:(CMServerFunction *)function
                              user:(CMUser *)user
                   extraParameters:(NSDictionary *)params
                    successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
                      errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST"
                                                                  URL:[self constructTextUrlAtUserLevel:(user != nil)
                                                                                               withKeys:nil
                                                                                                  query:nil
                                                                                          pagingOptions:nil
                                                                                         sortingOptions:nil
                                                                                 withServerSideFunction:function
                                                                                        extraParameters:params]
                                                            appSecret:_appSecret
                                                           binaryData:NO
                                                                 user:user];
    [request setHTTPBody:[data jsonData]];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

- (void)updateACL:(NSDictionary *)acl
             user:(CMUser *)user
   successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
     errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST"
                                                                  URL:[self constructACLUrlWithKey:nil query:nil extraParameters:nil]
                                                            appSecret:_appSecret
                                                           binaryData:NO
                                                                 user:user];
    [request setHTTPBody:[acl jsonData]];
    [self executeACLUpdateRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - POST requests for binary data

- (void)uploadBinaryData:(NSData *)data
      serverSideFunction:(CMServerFunction *)function
                   named:(NSString *)key
              ofMimeType:(NSString *)mimeType
                    user:(CMUser *)user
         extraParameters:(NSDictionary *)params
          successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"PUT"
                                                                  URL:[self constructBinaryUrlAtUserLevel:(user != nil)
                                                                                                  withKey:key
                                                                                   withServerSideFunction:function
                                                                                          extraParameters:params]
                                                            appSecret:_appSecret
                                                           binaryData:YES
                                                                 user:user];
    if (mimeType.length > 0) {
        [request setValue:mimeType forHTTPHeaderField:@"Content-Type"];
    }
    [request setHTTPBody:[data mutableCopy]];
    [self executeBinaryDataUploadRequest:request successHandler:successHandler errorHandler:errorHandler];
}

- (void)uploadFileAtPath:(NSString *)path
      serverSideFunction:(CMServerFunction *)function
                   named:(NSString *)key
              ofMimeType:(NSString *)mimeType
                    user:(CMUser *)user
         extraParameters:(NSDictionary *)params
          successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"PUT"
                                                                  URL:[self constructBinaryUrlAtUserLevel:(user != nil)
                                                                                                  withKey:key
                                                                                   withServerSideFunction:function
                                                                                          extraParameters:params]
                                                            appSecret:_appSecret
                                                           binaryData:YES
                                                                 user:user];
    if (mimeType.length > 0) {
        [request setValue:mimeType forHTTPHeaderField:@"Content-Type"];
    }
    
    // If file does not exist, all will just be nil
    NSError *error;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    unsigned long long fileSize = [[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
    [request setValue:[NSString stringWithFormat:@"%llu", fileSize] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:path]];
    
    [self executeBinaryDataUploadRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - PUT (replace) requests for non-binary data

- (void)setValuesFromDictionary:(NSDictionary *)data
             serverSideFunction:(CMServerFunction *)function
                           user:(CMUser *)user
                extraParameters:(NSDictionary *)params
                 successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
                   errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"PUT"
                                                                  URL:[self constructTextUrlAtUserLevel:(user != nil)
                                                                                               withKeys:nil
                                                                                                  query:nil
                                                                                          pagingOptions:nil
                                                                                         sortingOptions:nil
                                                                                 withServerSideFunction:function
                                                                                        extraParameters:params]
                                                            appSecret:_appSecret
                                                           binaryData:NO
                                                                 user:user];
    [request setHTTPBody:[data jsonData]];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - DELETE requests for data

- (void)deleteValuesForKeys:(NSArray *)keys
         serverSideFunction:(CMServerFunction *)function
                       user:(CMUser *)user
            extraParameters:(NSDictionary *)params
             successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
               errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSURLRequest *request = [self constructHTTPRequestWithVerb:@"DELETE" URL:[[self constructDataUrlAtUserLevel:(user != nil)
                                                                                                       withKeys:keys
                                                                                         withServerSideFunction:function
                                                                                                extraParameters:params]
                                                                              URLByAppendingAndEncodingQueryParameter:@"all" andValue:@"true"]
                                                     appSecret:_appSecret
                                                    binaryData:NO
                                                          user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

- (void)deleteACLWithKey:(NSString *)key
                    user:(CMUser *)user
          successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"DELETE"
                                                                  URL:[self constructACLUrlWithKey:key query:nil extraParameters:nil]
                                                            appSecret:_appSecret
                                                           binaryData:NO
                                                                 user:user];
    [self executeACLDeleteRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - Snippet execution

- (void)runSnippet:(NSString *)snippetName withParams:(NSDictionary *)params user:(CMUser *)user successHandler:(CMWebServiceSnippetRunSuccessCallback)successHandler errorHandler:(CMWebServiceSnippetRunFailureCallback)errorHandler {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/app/%@/run/%@", self.apiUrl, _appIdentifier, snippetName]];
    url = [url URLByAppendingAndEncodingQueryParameters:params];
    
    NSMutableURLRequest* request = [self constructHTTPRequestWithVerb:@"GET" URL:url appSecret:_appSecret binaryData:NO user:user];
    [self executeRequest:request successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
        successHandler(snippetResult, headers);
    } errorHandler:errorHandler];
}

- (void)runPOSTSnippet:(NSString *)snippetName withBody:(NSData *)body user:(CMUser *)user successHandler:(CMWebServiceSnippetRunSuccessCallback)successHandler errorHandler:(CMWebServiceSnippetRunFailureCallback)errorHandler {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/app/%@/run/%@", self.apiUrl, _appIdentifier, snippetName]];
    
    NSMutableURLRequest* request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:user];
    
    if (body != nil) {
        [request setHTTPBody:body];
    }
    
    [self executeRequest:request successHandler:^(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers) {
        successHandler(snippetResult, headers);
    } errorHandler:errorHandler];
    
}

#pragma mark - Push Notifications

- (void)registerForPushNotificationsWithUser:(CMUser *)user token:(NSData *)devToken callback:(CMWebServiceDeviceTokenCallback)callback {
    NSParameterAssert(devToken);
    
    NSString *tokenString = [NSString stringWithFormat:@"%@", devToken];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<|\\s|>)" options:NSRegularExpressionCaseInsensitive error:nil];
    tokenString = [regex stringByReplacingMatchesInString:tokenString options:0 range:NSMakeRange(0, [tokenString length]) withTemplate:@""];
    
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/device", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:user];
    [request setHTTPBody:[@{@"token" : tokenString} jsonData]];
    
    [self executeRequest:request resultHandler:^(id responseBody, NSError *errors, NSUInteger httpCode) {
        
        CMDeviceTokenResult result = CMDeviceTokenOperationFailed;
        switch (httpCode) {
            case 200:
                result = CMDeviceTokenUpdated;
                break;
            case 201:
                result = CMDeviceTokenUploadSuccess;
            default:
                break;
        }
        callback(result);
    }];
}

- (void)unRegisterForPushNotificationsWithUser:(CMUser *)user callback:(CMWebServiceDeviceTokenCallback)callback {
    
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/device", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"DELETE" URL:url appSecret:_appSecret binaryData:NO user:user];
    
    [self executeRequest:request resultHandler:^(id responseBody, NSError *errors, NSUInteger httpCode) {
        CMDeviceTokenResult result = CMDeviceTokenDeleted;
        if (httpCode == 404)
            result = CMDeviceTokenOperationFailed;
        callback(result);
    }];
}


- (void)subscribeThisDeviceToPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback {
    [self subscribeDevice:nil toPushChannel:channel callback:callback];
}

- (void)subscribeDevice:(NSString *)deviceID toPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback {
    [self _subscribeDevice:deviceID orUser:nil toPushChannel:channel callback:callback];
}

- (void)subscribeUser:(CMUser *)user toPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback {
    NSParameterAssert(user);
    NSAssert(user.isLoggedIn, @"The user must be logged in, in order to subscribe to a channel!");
    [self _subscribeDevice:nil orUser:user toPushChannel:channel callback:callback];
}

// Private
- (void)_subscribeDevice:(NSString *)deviceID orUser:(CMUser *)user toPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback {
    NSParameterAssert(channel);
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/push/channel/%@/subscribe", _appIdentifier, channel]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:user];
    
    NSMutableDictionary *subscribers = [NSMutableDictionary dictionary];
    
    if (user) {
        [subscribers setValue:@"true" forKey:@"user"];
    } else if (!user || deviceID) {
        [subscribers setValue:@"true" forKey:@"device"];
    }
    if (deviceID) {
        [subscribers setValue:deviceID forKey:@"device_id"];
    }
    
    [request setHTTPBody:[subscribers jsonData]];
    
    [self executeRequest:request resultHandler:^(id responseBody, NSError *errors, NSUInteger httpCode) {
        CMChannelResponse *result = [[CMChannelResponse alloc] initWithResponseBody:responseBody httpCode:httpCode error:errors];
        [result setValue:@YES forKey:@"subscribe"];
        callback(result);
    }];
}

- (void)unSubscribeThisDeviceFromPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback {
    [self unSubscribeDevice:nil fromPushChannel:channel callback:callback];
}

- (void)unSubscribeDevice:(NSString *)deviceID fromPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback {
    [self _unSubscribeDevice:deviceID orUser:nil fromPushChannel:channel callback:callback];
}

- (void)unSubscribeUser:(CMUser *)user fromPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback {
    NSParameterAssert(user);
    NSAssert(user.isLoggedIn, @"The user must be logged in, in order to subscribe to a channel!");
    [self _unSubscribeDevice:nil orUser:user fromPushChannel:channel callback:callback];
}

// Private
- (void)_unSubscribeDevice:(NSString *)deviceID orUser:(CMUser *)user fromPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback {
    NSParameterAssert(channel);
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/push/channel/%@/unsubscribe", _appIdentifier, channel]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:user];
    
    NSMutableDictionary *unsubscribers = [NSMutableDictionary dictionary];
    
    if (user) {
        [unsubscribers setValue:@"true" forKey:@"user"];
    } else if (!user || deviceID) {
        [unsubscribers setValue:@"true" forKey:@"device"];
    }
    if (deviceID) {
        [unsubscribers setValue:deviceID forKey:@"device_id"];
    }
    
    [request setHTTPBody:[unsubscribers jsonData]];
    
    // Right here, we should use a Response Object, encapsulate the HTTP code, give it an enum for happiness, and also catch any errors it may have.
    [self executeRequest:request resultHandler:^(id responseBody, NSError *errors, NSUInteger httpCode) {
        CMChannelResponse *result = [[CMChannelResponse alloc] initWithResponseBody:responseBody httpCode:httpCode error:errors];
        [result setValue:@NO forKey:@"subscribe"];
        callback(result);
    }];
}

- (void)getChannelsForThisDeviceWithCallback:(CMViewChannelsRequestCallback)callback {
    [self getChannelsForDevice:nil callback:callback];
}

- (void)getChannelsForDevice:(NSString *)deviceID callback:(CMViewChannelsRequestCallback)callback {
    NSURL *url = nil;
    if (deviceID) {
        url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/device/%@/channels", _appIdentifier, deviceID]];
    } else {
        url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/device/channels", _appIdentifier]];
    }
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"GET" URL:url appSecret:_appSecret binaryData:NO user:nil];
    
    [self executeRequest:request resultHandler:^(id responseBody, NSError *errors, NSUInteger httpCode) {
        CMViewChannelsResponse *response = [[CMViewChannelsResponse alloc] initWithResponseBody:responseBody httpCode:httpCode error:errors];
        callback(response);
    }];
}



#pragma mark - Singly Proxy

- (void)runSocialGraphGETQueryOnNetwork:(NSString *)network
                              baseQuery:(NSString *)base
                             parameters:(NSDictionary *)params
                                headers:(NSDictionary *)headers
                               withUser:(CMUser *)user
                         successHandler:(CMWebServicesSocialQuerySuccessCallback)successHandler
                           errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    [self runSocialGraphQueryOnNetwork:network
                              withVerb:@"GET"
                             baseQuery:base
                            parameters:params
                               headers:headers
                           messageData:nil
                              withUser:user
                        successHandler:successHandler
                          errorHandler:errorHandler];
    
}

- (void)runSocialGraphQueryOnNetwork:(NSString *)network
                            withVerb:(NSString *)verb
                           baseQuery:(NSString *)base
                          parameters:(NSDictionary *)params
                             headers:(NSDictionary *)headers
                         messageData:(NSData *)data
                            withUser:(CMUser *)user
                      successHandler:(CMWebServicesSocialQuerySuccessCallback)successHandler
                        errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    NSParameterAssert(user);
    NSAssert(user.isLoggedIn, @"Cannot send a query of a user who is not logged in!");
    
    NSString *url = [NSString stringWithFormat:@"%@/app/%@/user/social/%@/%@", self.apiUrl, _appIdentifier, network, base];
    NSURL *finalUrl = [NSURL URLWithString:url];
    
    if (params && [params count] != 0)
        finalUrl = [finalUrl URLByAppendingAndEncodingQueryParameter:@"params" andValue:[params jsonString]];
    
    if (headers && [headers count] != 0)
        finalUrl = [finalUrl URLByAppendingAndEncodingQueryParameter:@"headers" andValue:[headers jsonString]];
    
    
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:verb URL:finalUrl appSecret:_appSecret binaryData:(data ? YES : NO) user:user];
    
    if (data)
        [request setHTTPBody:data];
    
    [self executeSocialQuery:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - User account management

- (void)loginUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/login", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];
    
    NSString *userAuthField = user.email != nil ? user.email : user.username;
    
    CFHTTPMessageRef dummyRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), (__bridge CFURLRef)[request URL], kCFHTTPVersion1_1);
    CFHTTPMessageAddAuthentication(dummyRequest, nil, (__bridge CFStringRef)userAuthField, (__bridge CFStringRef)user.password, kCFHTTPAuthenticationSchemeBasic, FALSE);
    NSString *basicAuthValue = (__bridge_transfer NSString *)CFHTTPMessageCopyHeaderFieldValue(dummyRequest, CFSTR("Authorization"));
    [request setValue:basicAuthValue forHTTPHeaderField:@"Authorization"];
    CFRelease(dummyRequest);
    
    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode, NSError *error) {
        if (!httpResponseCode && error) {
            if ([[error domain] isEqualToString:CMErrorDomain]) {
                if ([error code] == CMErrorUnauthorized) {
                    return CMUserAccountLoginFailedIncorrectCredentials;
                } else if ([error code] == CMErrorServerConnectionFailed) {
                    return CMUserAccountUnknownResult;
                }
            }
        }
        
        switch (httpResponseCode) {
            case 200:
                return CMUserAccountLoginSucceeded;
            case 401:
                return CMUserAccountLoginFailedIncorrectCredentials;
            case 404:
                return CMUserAccountOperationFailedUnknownAccount;
            default:
                return CMUserAccountUnknownResult;
        }
    } callback:^(CMUserAccountResult resultCode, NSDictionary *messages) {
        switch (resultCode) {
            case CMUserAccountLoginFailedIncorrectCredentials:
                NSLog(@"CloudMine *** User login failed because the credentials provided were incorrect");
                break;
            case CMUserAccountOperationFailedUnknownAccount:
                NSLog(@"CloudMine *** User login failed because the application does not exist");
                break;
            default:
                break;
        }
        callback(resultCode, messages);
    }];
}



- (void)logoutUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    NSAssert(user.isLoggedIn, @"Cannot logout a user that hasn't been logged in.");
    
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/logout", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];
    [request setValue:user.token forHTTPHeaderField:CM_SESSIONTOKEN_HEADER];
    
    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode, NSError *error) {
        if ([[error domain] isEqualToString:CMErrorDomain]) {
            if ([error code] == CMErrorServerConnectionFailed) {
                return CMUserAccountUnknownResult;
            }
        }
        switch (httpResponseCode) {
            case 200:
                return CMUserAccountLogoutSucceeded;
            case 404:
                return CMUserAccountOperationFailedUnknownAccount;
            default:
                return CMUserAccountUnknownResult;
        }
    } callback:^(CMUserAccountResult resultCode, NSDictionary *messages) {
        switch (resultCode) {
            case CMUserAccountOperationFailedUnknownAccount:
                NSLog(@"CloudMine *** User logout failed because the application does not exist");
                break;
            default:
                break;
        }
        callback(resultCode, messages);
    }];
}

- (void)createAccountWithUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    NSAssert( (user.username != nil || user.email != nil) && user.password != nil, @"CloudMine *** User creation failed because the user object doesn't have a email/username or password set.");
    
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/create", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];
    
    // The userid, username, and password of this account are supplied in the request body.
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithObjectsAndKeys:user.password, @"password", nil];
    if (user.email) {
        [credentials setValue:user.email forKey:@"email"];
    }
    if (user.username) {
        [credentials setValue:user.username forKey:@"username"];
    }
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithObjectsAndKeys:credentials, @"credentials", nil];
    
    // Extract other profile fields from the user by serializing it to JSON and removing the "token" and "tokenExpiration" fields (which don't
    // need to be sent over the wire).
    NSMutableDictionary *serializedUser = [[[(NSDictionary *)[CMObjectEncoder encodeObjects:@[user]] allValues] objectAtIndex:0] mutableCopy];
    [serializedUser removeObjectsForKeys:@[@"token", @"tokenExpiration", @"userId"]];
    if ([serializedUser count] > 0) {
        [payload setObject:serializedUser forKey:@"profile"];
    }
    
    [request setHTTPBody:[payload jsonData]];
    
    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode, NSError *error) {
        if ([[error domain] isEqualToString:CMErrorDomain]) {
            if ([error code] == CMErrorServerConnectionFailed) {
                return CMUserAccountUnknownResult;
            }
        }
        switch (httpResponseCode) {
            case 201:
                return CMUserAccountCreateSucceeded;
            case 400:
                return CMUserAccountCreateFailedInvalidRequest;
            case 409:
                return CMUserAccountCreateFailedDuplicateAccount;
            default:
                return CMUserAccountUnknownResult;
        }
    } callback:^(CMUserAccountResult resultCode, NSDictionary *messages) {
        switch (resultCode) {
            case CMUserAccountCreateFailedInvalidRequest:
                NSLog(@"CloudMine *** User creation failed because the request was invalid");
                break;
            case CMUserAccountCreateFailedDuplicateAccount:
                NSLog(@"CloudMine *** User creation failed because the account already exists");
                break;
            default:
                break;
        }
        callback(resultCode, messages);
    }];
}

- (CMSocialLoginViewController *)loginWithSocial:(CMUser *)user
                                     withService:(NSString *)service
                                  viewController:(UIViewController *)viewController
                                          params:(NSDictionary *)params
                                        callback:(CMWebServiceUserAccountOperationCallback)callback;
{
    ///
    /// This method should return a controller no matter what, even if
    /// the user never ends up seeing it. This is confusing - but in some
    /// situations the user will be logged in through their already configured
    /// facebook or twitter accounts. However, access to these is asyncronous
    /// and uncertain. We return the controller no matter what, and if need
    /// be, we display it.
    ///
    CMSocialLoginViewController *controller =  [self loginWithSocialWebView:user
                                                                withService:service
                                                             viewController:viewController
                                                                     params:params
                                                                   callback:callback];
    
    if ([service isEqualToString:CMSocialNetworkTwitter]) {
        
        if (!_accountStore) {
            self.accountStore = [[ACAccountStore alloc] init];
        }
        
        ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        self.picker = [[CMSocialAccountChooser alloc] init];
        
        [_accountStore requestAccessToAccountsWithType:twitterType
                                                   options:nil
                                                completion:^(BOOL granted, NSError *error) {
                                                    if (!granted) {
                                                        [self.picker wouldLikeToLogInWithAnotherAccountWithCallback:^(BOOL answer) {
                                                            if (!answer) {
                                                                /// They do not want to login with Twitter.
                                                                return;
                                                            } else {
                                                                [viewController presentViewController:controller animated:YES completion:nil];
                                                            }
                                                        }];
                                                    } else {
                                                        /// We've been granted access, but if there are more than 1 account, we don't
                                                        /// know which one to login to. So we obtain all the local account instances...
                                                        /// Even if they only have 1 account, they may not want to log in to that one.
                                                        NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
                                                        [self.picker chooseFromAccounts:accounts
                                                                          showFrom:viewController
                                                                          callback:^(id account) {
                                                                              if ([account isKindOfClass:[NSNumber class]]) {
                                                                                  [viewController presentViewController:controller animated:YES completion:nil];
                                                                              } else if ([account isKindOfClass:[ACAccount class]]) {
                                                                                  [self reverseOAuthWithAccount:account
                                                                                                        service:service
                                                                                                           user:user
                                                                                                       callback:callback];
                                                                              }
                                                                          }];
                                                    }
                                                }];
        return nil;
        
    } else if (CMSocialNetworkFacebook) {
        Class klass = NSClassFromString(@"FBSession");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (klass) {
            id activeSession = [klass performSelector:NSSelectorFromString(@"activeSession")];
            if ([activeSession respondsToSelector:NSSelectorFromString(@"accessTokenData")]) {
                id data = [activeSession performSelector:NSSelectorFromString(@"accessTokenData")];
                if ([data respondsToSelector:NSSelectorFromString(@"accessToken")]) {
                    NSString *accessToken = [data performSelector:NSSelectorFromString(@"accessToken")];
                    if (accessToken) {
                        [user loginWithSocialNetwork:CMSocialNetworkFacebook
                                         accessToken:accessToken
                                         descriptors:nil
                                            callback:^(CMUserResponse *response) {
                                                if ([response wasSuccess] && callback) {
                                                    callback(CMUserAccountLoginSucceeded, response.body);
                                                } else if (![response wasSuccess]) {
                                                    [viewController presentViewController:controller animated:YES completion:nil];
                                                }
                                            }];
                        return controller;
                    }
                }
            }
        }
#pragma clang diagnostic pop
        
    }
    
    [viewController presentViewController:controller animated:YES completion:nil];
    return controller;
}

- (CMSocialLoginViewController *)loginWithSocialWebView:(CMUser *)user
                                            withService:(NSString *)service
                                         viewController:(UIViewController *)viewController
                                                 params:(NSDictionary *)params
                                               callback:(CMWebServiceUserAccountOperationCallback)callback;
{
    CMSocialLoginViewController *loginViewController = [[CMSocialLoginViewController alloc] initForService:service
                                                                                                     appID:_appIdentifier
                                                                                                    apiKey:_appSecret
                                                                                                      user:user
                                                                                                    params:params];
    loginViewController.baseURL = self.apiUrl;
    loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    loginViewController.delegate = self;
    temporaryCallback = callback;
    return loginViewController;
}

- (void)cmSocialLoginViewController:(CMSocialLoginViewController *)controller completeSocialLoginWithChallenge:(NSString *)challenge {
    // Request the session token info
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/social/login/status/%@", _appIdentifier, challenge]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"GET" URL:url appSecret:_appSecret binaryData:NO user:nil];
    
    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode, NSError *error) {
        if (!httpResponseCode && error) {
            if ([[error domain] isEqualToString:CMErrorDomain]) {
                if ([error code] == CMErrorUnauthorized) {
                    return CMUserAccountLoginFailedIncorrectCredentials;
                } else if ([error code] == CMErrorServerConnectionFailed) {
                    return CMUserAccountUnknownResult;
                }
            }
        }
        
        switch (httpResponseCode) {
            case 200:
                return CMUserAccountLoginSucceeded;
            case 401:
                return CMUserAccountLoginFailedIncorrectCredentials;
            case 404:
                return CMUserAccountOperationFailedUnknownAccount;
            default:
                return CMUserAccountUnknownResult;
        }
    } callback:^(CMUserAccountResult resultCode, NSDictionary *messages) {
        switch (resultCode) {
            case CMUserAccountLoginFailedIncorrectCredentials:
                NSLog(@"CloudMine *** User login failed because the credentials provided were incorrect");
                break;
            case CMUserAccountOperationFailedUnknownAccount:
                NSLog(@"CloudMine *** User login failed because the application does not exist");
                break;
            default:
                break;
        }
        
        if ([messages valueForKey:@"expires"] == [NSNull null]) {
            resultCode = CMUserAccountLoginFailedIncorrectCredentials;
        }
        
        if (temporaryCallback) {
            temporaryCallback(resultCode, messages);
        }
    }];
}


- (void)cmSocialLoginViewController:(CMSocialLoginViewController *)controller hadError:(NSError *)error {
    if (temporaryCallback) {
        temporaryCallback(CMUserAccountSocialLoginErrorOccurred, @{CMErrorDomain: error});
    }
}

- (void)cmSocialLoginViewControllerWasDismissed:(CMSocialLoginViewController *)controller {
    if (temporaryCallback) {
        temporaryCallback(CMUserAccountSocialLoginDismissed, nil);
    }
}

- (void)reverseOAuthWithAccount:(ACAccount *)account service:(NSString *)service user:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback;
{
    //perform API call
    NSURL *url = [self constructAppURLWithString:[NSString stringWithFormat:@"account/social/%@/reverse", service] andDescriptors:nil];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url binaryData:NO user:nil]; //TODO: user
    
    [self executeGenericRequest:request
                 successHandler:^(id parsedBody, NSUInteger httpCode, NSDictionary *headers) {
                     NSLog(@"Parsed Body from Reverse OAuth: %@", parsedBody);
                     [self makeSLRequestWith:parsedBody[@"consumer_key"] account:account oauth:parsedBody[@"oauth"] user:user callback:callback];
                 } errorHandler:^(id responseBody, NSUInteger httpCode, NSDictionary *headers, NSError *error, NSDictionary *errorInfo) {
                     if (callback) {
                         callback(CMUserAccountUnknownResult, @{@"error": error});
                     }
                 }];
}

- (void)makeSLRequestWith:(NSString *)consumerKey
                  account:(ACAccount *)account
                    oauth:(NSString *)oauth
                     user:(CMUser *)user
                 callback:(CMWebServiceUserAccountOperationCallback)callback;
{
    NSMutableDictionary *step2Params = [[NSMutableDictionary alloc] init];
    step2Params[@"x_reverse_auth_target"] = consumerKey;
    step2Params[@"x_reverse_auth_parameters"] = oauth;
    
    NSURL *url2 = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
    SLRequest *stepTwoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                   requestMethod:SLRequestMethodPOST
                                                             URL:url2
                                                      parameters:step2Params];
    
    [stepTwoRequest setAccount:account];
    
    [stepTwoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Twitter Request Response: %@", responseStr);
        [self createUser:user response:responseStr callback:callback];
    }];
}

- (void)createUser:(CMUser *)user response:(NSString *)response callback:(CMWebServiceUserAccountOperationCallback)callback;
{
    NSArray *parts = [response componentsSeparatedByString:@"&"];
    NSString *token = [parts[0] componentsSeparatedByString:@"="][1];
    NSString *secret = [parts[1] componentsSeparatedByString:@"="][1];
    
    NSLog(@"Token: %@ - Secret: %@", token, secret);
    
    [user loginWithSocialNetwork:CMSocialNetworkTwitter
                      oauthToken:token
                oauthTokenSecret:secret
                     descriptors:nil
                        callback:^(CMUserResponse *response) {
                            if ([response wasSuccess] && callback) {
                                callback(CMUserAccountLoginSucceeded, response.body);
                            } else if (![response wasSuccess] && callback) {
                                callback(CMUserAccountCreateFailedInvalidRequest, response.body);
                            }
                        }];
}


- (void)saveUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    
    if (user.isCreatedRemotely) {
        // The user has already been saved, so just update the profile. In order for this to work, the user must be logged in.
        
        void (^save)() = ^{
            NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/%@", _appIdentifier, user.objectId]];
            NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:user];
            NSMutableDictionary *payload = [[[CMObjectEncoder encodeObjects:[NSSet setWithObject:user]] objectForKey:user.objectId] mutableCopy]; // Don't need the outer object wrapping it like with objects
            // This should include all blacklisted keys
            [payload removeObjectsForKeys:@[@"token", @"tokenExpiration", @"userId"]];
            [request setHTTPBody:[payload jsonData]];
            
            AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseString = [operation responseString];
                
                // Parse responsibly. If error is not handled, it will crash the application!
                NSError *parseErr = nil;
                NSDictionary *results = [NSDictionary dictionary];
                if (responseString != nil) {
                    NSDictionary *parsedResults = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                                  options:0
                                                                                    error:&parseErr];
                    if (!parseErr && parsedResults) {
                        results = parsedResults;
                    }
                }
                
                // Handle any service errors, or report success
                if ([[operation response] statusCode] == 200 && [(NSArray *)results[@"errors"] count] == 0) {
                    callback(CMUserAccountProfileUpdateSucceeded, results);
                } else {
                    callback(CMUserAccountProfileUpdateFailed, [results objectForKey:@"errors"]);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if ([[error domain] isEqualToString:NSURLErrorDomain]) {
                    if ([error code] == NSURLErrorUserCancelledAuthentication) {
                        error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
                    } else {
                        error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"A connection to the server was not able to be established.", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
                    }
                }
                NSLog(@"CloudMine *** User profile save operation failed (%@)", [error localizedDescription]);
                
                if (callback) {
                    callback(CMUserAccountProfileUpdateFailed, nil);
                }
            }];
            
            [requestOperation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
                
            }];
            
            [self enqueueHTTPRequestOperation:requestOperation];
        };
        
        if (!user.isLoggedIn) {
            if ( (!user.email || !user.username) && !user.password) {
                NSLog(@"CloudMine *** Cannot update a user profile when the user is not logged in and userId and password are not both set.");
                if (callback) {
                    callback(CMUserAccountLoginFailedIncorrectCredentials, [NSDictionary dictionary]);
                }
                return;
            }
            
            // User must be logged in for this to work, so try logging them in.
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                if (CMUserAccountOperationFailed(resultCode)) {
                    // If login failed, pass the error through.
                    if (callback) {
                        callback(resultCode, [NSDictionary dictionary]);
                    }
                } else {
                    // Otherwise continue with saving the updates.
                    save(callback);
                }
            }];
        } else {
            // Everything looks good, so proceed with the saving.
            save(callback);
        }
    } else {
        // Since the user hasn't been created remotely yet, just create it like usual.
        [self createAccountWithUser:user callback:callback];
    }
}

- (void)changePasswordForUser:(CMUser *)user oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    NSParameterAssert(oldPassword);
    NSParameterAssert(newPassword);
    NSAssert(user.email, @"CloudMine *** User password change failed because the user object doesn't have a email set.");
    
    [self changeCredentialsForUser:user password:oldPassword newPassword:newPassword newUsername:nil newEmail:nil callback:callback];
}

- (void)changeCredentialsForUser:(CMUser *)user
                        password:(NSString *)password
                     newPassword:(NSString *)newPassword
                     newUsername:(NSString *)newUsername
                       newUserId:(NSString *)newUserId
                        callback:(CMWebServiceUserAccountOperationCallback)callback {
    [self changeCredentialsForUser:user password:password newPassword:newPassword newUsername:newUsername newEmail:newUserId callback:callback];
}

- (void)changeCredentialsForUser:(CMUser *)user
                        password:(NSString *)password
                     newPassword:(NSString *)newPassword
                     newUsername:(NSString *)newUsername
                        newEmail:(NSString *)newEmail
                        callback:(CMWebServiceUserAccountOperationCallback)callback {
    
    NSParameterAssert(user);
    NSParameterAssert(password);
    NSAssert( user.username != nil || user.email != nil, @"CloudMine *** User credential change failed because the user object doesn't have a email/username set.");
    
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/credentials", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];
    
    NSString *userAuthField = user.email != nil ? user.email : user.username;
    
    // This API endpoint doesn't use a session token for security purposes. The user must supply their old password
    // explicitly in addition to their new password.
    CFHTTPMessageRef dummyRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), (__bridge CFURLRef)[request URL], kCFHTTPVersion1_1);
    CFHTTPMessageAddAuthentication(dummyRequest, nil, (__bridge CFStringRef)userAuthField, (__bridge CFStringRef)password, kCFHTTPAuthenticationSchemeBasic, FALSE);
    NSString *basicAuthValue = (__bridge_transfer NSString *)CFHTTPMessageCopyHeaderFieldValue(dummyRequest, CFSTR("Authorization"));
    [request setValue:basicAuthValue forHTTPHeaderField:@"Authorization"];
    CFRelease(dummyRequest);
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    if (newPassword) { [payload setValue:newPassword forKey:@"password"]; }
    if (newUsername) { [payload setValue:newUsername forKey:@"username"]; }
    if (newEmail) { [payload setValue:newEmail forKey:@"email"]; }
    
    [request setHTTPBody:[payload jsonData]];
    
    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode, NSError *error) {
        if ([[error domain] isEqualToString:CMErrorDomain]) {
            if ([error code] == CMErrorUnauthorized) {
                return CMUserAccountPasswordChangeFailedInvalidCredentials;
            } else if ([error code] == CMErrorServerConnectionFailed) {
                return CMUserAccountUnknownResult;
            }
        }
        switch (httpResponseCode) {
            case 200:
                if ( (newPassword && newUsername && newEmail) || (newPassword && newUsername) || (newPassword && newEmail) || (newUsername && newEmail) ) {
                    return CMUserAccountCredentialChangeSucceeded;
                } else if (newPassword) {
                    return CMUserAccountPasswordChangeSucceeded;
                } else if (newUsername) {
                    return CMUserAccountUsernameChangeSucceeded;
                } else {
                    return CMUserAccountEmailChangeSucceeded;
                }
            case 401:
                if (newPassword && newEmail == nil && newUsername == nil)
                    return CMUserAccountPasswordChangeFailedInvalidCredentials;
                
                return CMUserAccountCredentialChangeFailedInvalidCredentials;
            case 404:
                return CMUserAccountOperationFailedUnknownAccount;
            case 409:
                if (newEmail && newUsername)
                    return CMUserAccountCredentialChangeFailedDuplicateInfo;
                if (newEmail)
                    return CMUserAccountCredentialChangeFailedDuplicateEmail;
                if (newUsername)
                    return CMUserAccountCredentialChangeFailedDuplicateUsername;
                
                return CMUserAccountCredentialChangeFailedDuplicateInfo;
            default:
                return CMUserAccountUnknownResult;
        }
    } callback:^(CMUserAccountResult resultCode, NSDictionary *messages) {
        
        NSLog(@"MESSAGES: %@", messages);
        switch (resultCode) {
            case CMUserAccountPasswordChangeFailedInvalidCredentials:
                NSLog(@"CloudMine *** User Credential change failed because the credentials provided were incorrect");
                break;
            case CMUserAccountOperationFailedUnknownAccount:
                NSLog(@"CloudMine *** User Credential change failed because the application does not exist");
                break;
            default:
                break;
        }
        callback(resultCode, messages);
    }];
    
    
}


- (void)resetForgottenPasswordForUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    NSAssert(user.email, @"CloudMine *** User password reset failed because the user object doesn't have an email set.");
    
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/password/reset", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];
    
    NSDictionary *payload = @{@"email" : user.email};
    [request setHTTPBody:[payload jsonData]];
    
    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode, NSError *error) {
        if ([[error domain] isEqualToString:CMErrorDomain]) {
            if ([error code] == CMErrorServerConnectionFailed) {
                return CMUserAccountUnknownResult;
            }
        }
        switch (httpResponseCode) {
            case 200:
                return CMUserAccountPasswordResetEmailSent;
            case 404:
                return CMUserAccountOperationFailedUnknownAccount;
            default:
                return CMUserAccountUnknownResult;
        }
    }
                                 callback:callback];
}

- (void)getAllUsersWithCallback:(CMWebServiceUserFetchSuccessCallback)callback {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                                  URL:[self constructAccountUrlWithUserIdentifier:nil query:nil]
                                                            appSecret:_appSecret
                                                           binaryData:NO
                                                                 user:nil];
    [self executeUserProfileFetchRequest:request callback:callback];
    
}

- (void)getUserProfileWithIdentifier:(NSString *)identifier
                            callback:(CMWebServiceUserFetchSuccessCallback)callback {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                                  URL:[self constructAccountUrlWithUserIdentifier:identifier query:nil]
                                                            appSecret:_appSecret
                                                           binaryData:NO
                                                                 user:nil];
    [self executeUserProfileFetchRequest:request callback:callback];
}

- (void)searchUsers:(NSString *)query callback:(CMWebServiceUserFetchSuccessCallback)callback {
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                                  URL:[self constructAccountUrlWithUserIdentifier:nil query:query]
                                                            appSecret:_appSecret
                                                           binaryData:NO
                                                                 user:nil];
    [self executeUserProfileFetchRequest:request callback:callback];
}

#pragma - Request queueing and execution

- (void)executeUserProfileFetchRequest:(NSMutableURLRequest *)request
                              callback:(CMWebServiceUserFetchSuccessCallback)callback {
    // TODO: Let this switch between MsgPack and GZIP'd JSON.
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDate *startDate = [NSDate date];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        NSString *responseString = [operation responseString];
        
        NSError *parseErr = nil;
        NSDictionary *responseBody = [NSDictionary dictionary];
        if (responseString != nil) {
            NSDictionary *parsedResponseBody = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                               options:0
                                                                                 error:&parseErr];
            if (!parseErr && parsedResponseBody) {
                responseBody = parsedResponseBody;
            }
        }
        
        if (callback != nil) {
            void (^block)() = ^{ callback(responseBody[@"success"],
                                          responseBody[@"errors"],
                                          @([(NSArray *)responseBody[@"success"] count])); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            if ([error code] == NSURLErrorUserCancelledAuthentication) {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            } else {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"A connection to the server was not able to be established.", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            }
        }
        
        NSLog(@"CloudMine *** User profile fetch operation failed (%@)", [error localizedDescription]);
        if (callback) {
            callback(nil, nil, nil);
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

- (void)executeUserAccountActionRequest:(NSMutableURLRequest *)request
                             codeMapper:(_CMWebServiceAccountResponseCodeMapper)codeMapper
                               callback:(CMWebServiceUserAccountOperationCallback)callback {
    
    // TODO: Let this switch between MsgPack and GZIP'd JSON.
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDate *startDate = [NSDate date];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        NSString *responseString = [operation responseString];
        
        CMUserAccountResult resultCode = codeMapper([operation.response statusCode], nil);
        
        NSError *parseErr = nil;
        NSDictionary *responseBody = [NSDictionary dictionary];
        if (responseString != nil) {
            NSDictionary *parsedResponseBody = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                               options:0
                                                                                 error:&parseErr];
            if (!parseErr && parsedResponseBody) {
                responseBody = parsedResponseBody;
            }
        }
        
        if (resultCode == CMUserAccountUnknownResult) {
            NSLog(@"CloudMine *** Unexpected response received from server during user account operation. (%@) (Code %ld) Body: %@", [parseErr localizedDescription], (long)[operation.response statusCode], responseString);
        }
        
        if (callback != nil) {
            void (^block)() = ^{ callback(resultCode, responseBody); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        CMUserAccountResult resultCode = codeMapper([operation.response statusCode], error);
        
        if (callback != nil) {
            void (^block)() = ^{ callback(resultCode, [NSDictionary dictionary]); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

- (void)executeSocialQuery:(NSURLRequest *)request successHandler:(CMWebServicesSocialQuerySuccessCallback)successHandler errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    
    NSDate *startDate = [NSDate date];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        NSString *responseString = [operation responseString];
        
        if (successHandler != nil) {
            void (^block)() = ^{ successHandler( responseString, [operation.response allHeaderFields]); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @(operation.response.statusCode), @"httpCode",
                                          operation.responseData, @"responseData",
                                          operation.responseString, @"responseString",
                                          [operation.response allHeaderFields], @"responseHeaders",
                                          error, NSURLErrorKey,
                                          nil];
        
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            if ([error code] == NSURLErrorUserCancelledAuthentication) {
                [errorInfo setValue:@"The request was unauthorized. Is your API key correct? Did the receiving service require authentication?" forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:errorInfo];
            } else {
                [errorInfo setValue:@"A connection to the server was not able to be established." forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:errorInfo];
            }
        }
        
        switch ([operation.response statusCode]) {
            case 404:
                [errorInfo setValue:@"The application was not found. Is your application identifier correct? Or perhaps the page you were looking for in the query does not exist." forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorNotFound userInfo:errorInfo];
                break;
                
            case 401:
                [errorInfo setValue:@"The request was unauthorized. Is your API key correct? Did the receiving service require authentication?" forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:errorInfo];
                break;
                
            case 400:
                [errorInfo setValue:@"The request was malformed." forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:errorInfo];
                break;
                
            case 500:
                [errorInfo setValue:@"The server experienced an error." forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerError userInfo:errorInfo];
                break;
                
            default:
                // Another error message, pass back status code
                break;
        }
        
        NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
        if (errorHandler != nil) {
            void (^block)() = ^{ errorHandler(error); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
    
}

- (void)executeGenericRequest:(NSURLRequest *)request successHandler:(CMWebServiceGenericRequestCallback)successHandler errorHandler:(CMWebServiceErorCallack)errorHandler {
    
        NSDate *startDate = [NSDate date];
    
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
                NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
                if (requestId) {
                        int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
                        [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
                }

            NSError *parseError;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                    options:0
                                                                      error:&parseError];
            
            if ([[parseError domain] isEqualToString:NSCocoaErrorDomain]) {
                NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response received from the server was malformed and could not be parsed.", NSLocalizedDescriptionKey, parseError, JSONErrorKey, nil]];
                NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
                if (errorHandler != nil) {
                    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      @(operation.response.statusCode), @"httpCode",
                                                      operation.responseData, @"responseData",
                                                      operation.responseString, @"responseString",
                                                      [operation.response allHeaderFields], @"responseHeaders",
                                                      error, NSURLErrorKey,
                                                      nil];
                    
                    void (^block)() = ^{ errorHandler(operation.responseData, operation.response.statusCode, operation.response.allHeaderFields, error, errorInfo); };
                    [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
                }
                return;
            }
            
            
            if (successHandler != nil) {
                void (^block)() = ^{ successHandler(results, operation.response.statusCode, operation.response.allHeaderFields); };
                [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              @(operation.response.statusCode), @"httpCode",
                                              operation.responseData, @"responseData",
                                              operation.responseString, @"responseString",
                                              [operation.response allHeaderFields], @"responseHeaders",
                                              error, NSURLErrorKey,
                                              nil];
            
            if ([[error domain] isEqualToString:NSURLErrorDomain]) {
                if ([error code] == NSURLErrorUserCancelledAuthentication) {
                    [errorInfo setValue:@"The request was unauthorized. Is your API key correct? Did the receiving service require authentication?" forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:errorInfo];
                } else {
                    [errorInfo setValue:@"A connection to the server was not able to be established." forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:errorInfo];
                }
            }
            
            switch ([operation.response statusCode]) {
                case 404:
                    [errorInfo setValue:@"The application was not found. Is your application identifier correct? Or perhaps the page you were looking for in the query does not exist." forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:CMErrorDomain code:CMErrorNotFound userInfo:errorInfo];
                    break;
                    
                case 401:
                    [errorInfo setValue:@"The request was unauthorized. Is your API key correct? Did the receiving service require authentication?" forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:errorInfo];
                    break;
                    
                case 400:
                    [errorInfo setValue:@"The request was malformed." forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:errorInfo];
                    break;
                    
                case 500:
                    [errorInfo setValue:@"The server experienced an error." forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerError userInfo:errorInfo];
                    break;
                    
                default:
                    // Another error message, pass back status code
                    break;
            }
            
            if (errorHandler != nil) {
                void (^block)() = ^{ errorHandler(operation.responseData, operation.response.statusCode, operation.response.allHeaderFields, error, errorInfo); };
                [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
            }
            
        }];
    [self enqueueHTTPRequestOperation:operation];
}


- (void)executeRequest:(NSURLRequest *)request
        successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
          errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    NSDate *startDate = [NSDate date];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        NSError *parseError;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                options:0
                                                                  error:&parseError];
        
        if ([[parseError domain] isEqualToString:NSCocoaErrorDomain]) {
            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response received from the server was malformed.", NSLocalizedDescriptionKey, parseError, JSONErrorKey, nil]];
            NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
            if (errorHandler != nil) {
                void (^block)() = ^{ errorHandler(error); };
                [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
            }
            return;
        }
        
        NSDictionary *successes = nil;
        NSDictionary *errors = nil;
        NSDictionary *meta = nil;
        NSNumber *count = nil;
        
        id snippetResult = nil;
        if (results) {
            successes = [results objectForKey:@"success"];
            if (!successes) {
                successes = [NSDictionary dictionary];
            }
            
            errors = [results objectForKey:@"errors"];
            if (!errors) {
                errors = [NSDictionary dictionary];
            }
            
            snippetResult = [results objectForKey:@"result"];
            if(!snippetResult) {
                snippetResult = [NSDictionary dictionary];
            }
            
            meta = [results objectForKey:@"meta"];
            if(!meta) {
                meta = [NSDictionary dictionary];
            }
            
            count = [results objectForKey:@"count"];
        }
        
        if (successHandler != nil) {
            void (^block)() = ^{ successHandler(successes, errors, meta, snippetResult, count, [operation.response allHeaderFields]); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            if ([error code] == NSURLErrorUserCancelledAuthentication) {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            } else {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"A connection to the server was not able to be established.", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            }
        }
        
        switch ([operation.response statusCode]) {
            case 404:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorNotFound userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The application was not found. Is your application identifier correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 401:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 400:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was malformed.", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 500:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The server experienced an error", NSLocalizedDescriptionKey, nil]];
                break;
                
            default:
                break;
        }
        
        NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
        if (errorHandler != nil) {
            void (^block)() = ^{ errorHandler(error); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

- (void)executeRequest:(NSURLRequest *)request
         resultHandler:(CMWebServiceResultCallback)handler {
    
    NSDate *startDate = [NSDate date];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        NSError *parseError;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                options:0
                                                                  error:&parseError];
        
        if ([[parseError domain] isEqualToString:NSCocoaErrorDomain]) {
            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response received from the server was malformed.", NSLocalizedDescriptionKey, parseError, JSONErrorKey, nil]];
            NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
            if (handler != nil) {
                void (^block)() = ^{ handler(results, error, operation.response.statusCode); };
                [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
            }
            return;
        }
        
        if (handler != nil) {
            void (^block)() = ^{ handler(results, nil, operation.response.statusCode); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (handler != nil) {
            void (^block)() = ^{ handler([operation responseString], error, operation.response.statusCode); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
    
    
}

- (void)executeACLUpdateRequest:(NSURLRequest *)request
                 successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
                   errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    NSDate *startDate = [NSDate date];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        NSError *parseError;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                options:0
                                                                  error:&parseError];
        
        if ([[parseError domain] isEqualToString:NSCocoaErrorDomain]) {
            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response received from the server was malformed.", NSLocalizedDescriptionKey, parseError, JSONErrorKey, nil]];
            NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
            if (errorHandler != nil) {
                void (^block)() = ^{ errorHandler(error); };
                [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
            }
            return;
        }
        
        if (successHandler != nil) {
            void (^block)() = ^{ successHandler(results, nil, nil, nil, [NSNumber numberWithUnsignedInteger:results.count], [operation.response allHeaderFields]); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            if ([error code] == NSURLErrorUserCancelledAuthentication) {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            } else {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"A connection to the server was not able to be established.", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            }
        }
        
        switch ([operation.response statusCode]) {
            case 404:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorNotFound userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Either the ACL or the entire application was not found. Does the ACL exist? Is your application identifier correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 401:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Are you authoried to do this? Is your API key correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 400:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was malformed.", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 500:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The server experienced an error", NSLocalizedDescriptionKey, nil]];
                break;
                
            default:
                break;
        }
        
        NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
        if (errorHandler != nil) {
            void (^block)() = ^{ errorHandler(error); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

- (void)executeACLDeleteRequest:(NSURLRequest *)request
                 successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
                   errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successHandler != nil) {
            void (^block)() = ^{ successHandler([NSDictionary dictionaryWithObject:@"deleted" forKey:[[request URL] lastPathComponent]], nil, nil, nil, [NSNumber numberWithUnsignedInt:1], [operation.response allHeaderFields]); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            if ([error code] == NSURLErrorUserCancelledAuthentication) {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            } else {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"A connection to the server was not able to be established.", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            }
        }
        
        switch ([operation.response statusCode]) {
            case 404:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorNotFound userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Either the ACL or the entire application was not found. Does the ACL exist? Is your application identifier correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 401:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Are you authoried to do this? Is your API key correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 400:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was malformed.", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 500:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The server experienced an error", NSLocalizedDescriptionKey, nil]];
                break;
                
            default:
                break;
        }
        
        NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
        if (errorHandler != nil) {
            void (^block)() = ^{ errorHandler(error); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

- (void)executeBinaryDataFetchRequest:(NSURLRequest *)request
                       successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler
                         errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    NSDate *startDate = [NSDate date];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        if (successHandler != nil) {
            void (^block)() = ^{ successHandler([operation responseData], [[operation.response allHeaderFields] objectForKey:@"Content-Type"], [operation.response allHeaderFields]); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            if ([error code] == NSURLErrorUserCancelledAuthentication) {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            } else {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"A connection to the server was not able to be established.", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            }
        }
        
        switch ([operation.response statusCode]) {
            case 404:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorNotFound userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Either the file was not found or the application itself was not found.", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 401:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 400:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was malformed.", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 500:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The server experienced an error", NSLocalizedDescriptionKey, nil]];
                break;
                
            default:
                break;
        }
        
        NSLog(@"CloudMine *** Unexpected error occurred during binary download request. (%@)", [error localizedDescription]);
        if (errorHandler != nil) {
            void (^block)() = ^{ errorHandler(error); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

- (void)executeBinaryDataUploadRequest:(NSURLRequest *)request
                        successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler
                          errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {
    
    NSDate *startDate = [NSDate date];
    
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        NSError *parseError;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                options:0
                                                                  error:&parseError];
        
        if ([[parseError domain] isEqualToString:NSCocoaErrorDomain]) {
            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response received from the server was malformed.", NSLocalizedDescriptionKey, parseError, JSONErrorKey, nil]];
            NSLog(@"CloudMine *** Unexpected error occurred during object request. (%@)", [error localizedDescription]);
            if (errorHandler != nil) {
                void (^block)() = ^{ errorHandler(error); };
                [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
            }
            return;
        }
        
        id snippetResult = nil;
        NSString *key = [results objectForKey:@"key"];
        
        if (results) {
            snippetResult = [results objectForKey:@"result"];
            if (!snippetResult)
                snippetResult = [NSDictionary dictionary];
        }
        
        if (successHandler != nil) {
            void (^block)() = ^{ successHandler([operation.response statusCode] == 201 ? CMFileCreated : CMFileUpdated, key, snippetResult, [operation.response allHeaderFields]); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *requestId = [[operation.response allHeaderFields] objectForKey:@"X-Request-Id"];
        if (requestId) {
            int milliseconds = (int)([[NSDate date] timeIntervalSinceDate:startDate] * 1000.0f);
            [_responseTimes setObject:[NSNumber numberWithInt:milliseconds] forKey:requestId];
        }
        
        if ([[error domain] isEqualToString:NSURLErrorDomain]) {
            if ([error code] == NSURLErrorUserCancelledAuthentication) {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            } else {
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerConnectionFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"A connection to the server was not able to be established.", NSLocalizedDescriptionKey, error, NSURLErrorKey, nil]];
            }
        }
        
        switch ([operation.response statusCode]) {
            case 404:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorNotFound userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The application was not found. Is your application identifier correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 401:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorUnauthorized userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was unauthorized. Is your API key correct?", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 400:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The request was malformed.", NSLocalizedDescriptionKey, nil]];
                break;
                
            case 500:
                error = [NSError errorWithDomain:CMErrorDomain code:CMErrorServerError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The server experienced an error", NSLocalizedDescriptionKey, nil]];
                break;
                
            default:
                break;
        }
        
        NSLog(@"CloudMine *** Unexpected error occurred during binary upload request. (%@)", [error localizedDescription]);
        if (errorHandler != nil) {
            void (^block)() = ^{ errorHandler(error); };
            [self performSelectorOnMainThread:@selector(performBlock:) withObject:block waitUntilDone:YES];
        }
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
    [super enqueueHTTPRequestOperation:operation];
}

- (void)performBlock:(void (^)())block {
    block();
}

#pragma - Request construction

- (NSMutableURLRequest *)constructHTTPRequestWithVerb:(NSString *)verb
                                                  URL:(NSURL *)url
                                            appSecret:(NSString *)appSecret
                                           binaryData:(BOOL)isForBinaryData
                                                 user:(CMUser *)user;
{
    NSAssert([_validHTTPVerbs containsObject:verb], @"You must pass in a valid HTTP verb. Possible choices are: GET, POST, PUT, and DELETE");
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:verb];
    if (user) {
        if (user.token == nil) {
            [[NSException exceptionWithName:@"CMInternalInconsistencyException" reason:@"You cannot construct a user-level CloudMine request when the user isn't logged in." userInfo:nil] raise];
            __builtin_unreachable();
        }
        [request setValue:user.token forHTTPHeaderField:CM_SESSIONTOKEN_HEADER];
    }
    [request setValue:appSecret forHTTPHeaderField:CM_APIKEY_HEADER];
    
    // TODO: This should be customizable to change between JSON, GZIP'd JSON, and MsgPack.
    
    // Don't do this for binary data since that requires further intervention by the developer.
    if (!isForBinaryData) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    
    // Add response times to user token string
    NSMutableArray *times = [NSMutableArray array];
    for (NSString *key in [_responseTimes allKeys]) {
        [times addObject:[NSString stringWithFormat:@"%@:%@", key, [_responseTimes[key] stringValue]]];
    }
    [_responseTimes removeAllObjects];
    if (times.count > 20)
        [times removeObjectsInRange:NSMakeRange(20, times.count - 20)];
    NSString *activeIdentifier = [[CMActiveUser currentActiveUser] identifier];
    NSString *userToken = times.count ? [NSString stringWithFormat:@"%@;%@", activeIdentifier, [times componentsJoinedByString:@","]] : activeIdentifier;
    
    // Add user agent and user tracking headers
    [request setValue:[NSString stringWithFormat:@"CM-iOS/%@", CM_VERSION] forHTTPHeaderField:@"X-CloudMine-Agent"];
    [request setValue:userToken forHTTPHeaderField:@"X-CloudMine-UT"];
    
#ifdef DEBUG
    NSLog(@"Constructed CloudMine URL: %@\nHeaders:%@", [request URL], [request allHTTPHeaderFields]);
#endif
    
    return [request copy];
    
    
}

- (NSMutableURLRequest *)constructHTTPRequestWithVerb:(NSString *)verb
                                                  URL:(NSURL *)url
                                           binaryData:(BOOL)isForBinaryData
                                                 user:(CMUser *)user {
    return [self constructHTTPRequestWithVerb:verb URL:url appSecret:_appSecret binaryData:isForBinaryData user:user];
    
}

#pragma mark - General URL construction

- (NSURL *)constructAppURLWithString:(NSString *)url andDescriptors:(NSArray *)descriptors {
    NSURL *returnURL = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/%@", _appIdentifier, url]];
    
    for (id descriptor in descriptors) {
        returnURL = [returnURL URLByAppendingAndEncodingQuery:[descriptor stringRepresentation]];
    }
    
    return returnURL;
}


- (NSURL *)constructACLUrlWithKey:(NSString *)key query:(NSString *)query extraParameters:(NSDictionary *)params {
    NSAssert(key == nil || query == nil, @"When constructing CM URLs, 'key' and 'query' are mutually exclusive");
    
    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/user/access", _appIdentifier]];
    
    if (query)
        url = [url URLByAppendingPathComponent:@"search"];
    
    if (key)
        url = [url URLByAppendingPathComponent:key];
    
    return [self appendKeys:nil query:query serverSideFunction:nil pagingOptions:nil sortingOptions:nil toURL:url extraParameters:params];
}

- (NSURL *)constructTextUrlAtUserLevel:(BOOL)atUserLevel
                              withKeys:(NSArray *)keys
                                 query:(NSString *)searchString
                         pagingOptions:(CMPagingDescriptor *)paging
                        sortingOptions:(CMSortDescriptor *)sorting
                withServerSideFunction:(CMServerFunction *)function
                       extraParameters:params {
    
    NSAssert(keys == nil || searchString == nil, @"When constructing CM URLs, 'keys' and 'searchString' are mutually exclusive");
    
    NSString *endpoint = nil;
    if (searchString != nil) {
        endpoint = @"search";
    } else {
        endpoint = @"text";
    }
    
    NSURL *url;
    if (atUserLevel) {
        url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/user/%@", _appIdentifier, endpoint]];
    } else {
        url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/%@", _appIdentifier, endpoint]];
    }
    
    return [self appendKeys:keys query:searchString serverSideFunction:function pagingOptions:paging sortingOptions:sorting toURL:url extraParameters:params];
}

- (NSURL *)constructBinaryUrlAtUserLevel:(BOOL)atUserLevel
                                 withKey:(NSString *)key
                  withServerSideFunction:(CMServerFunction *)function
                         extraParameters:(NSDictionary *)params {
    NSURL *url;
    if (atUserLevel) {
        url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/user/binary", _appIdentifier]];
    } else {
        url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/binary", _appIdentifier]];
    }
    
    if (key) {
        url = [url URLByAppendingPathComponent:key];
    }
    
    return [self appendKeys:nil query:nil serverSideFunction:function pagingOptions:nil sortingOptions:nil toURL:url extraParameters:params];
}

- (NSURL *)constructDataUrlAtUserLevel:(BOOL)atUserLevel
                              withKeys:(NSArray *)keys
                withServerSideFunction:(CMServerFunction *)function
                       extraParameters:(NSDictionary *)params {
    NSURL *url;
    if (atUserLevel) {
        url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/user/data", _appIdentifier]];
    } else {
        url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/data", _appIdentifier]];
    }
    
    return [self appendKeys:keys query:nil serverSideFunction:function pagingOptions:nil sortingOptions:nil toURL:url extraParameters:params];
}

- (NSURL *)constructAccountUrlWithUserIdentifier:(NSString *)userId
                                           query:(NSString *)query {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/app/%@/account", self.apiUrl, _appIdentifier]];
    if (userId) {
        url = [url URLByAppendingPathComponent:userId];
    } else if (query) {
        url = [url URLByAppendingPathComponent:@"search"];
        url = [url URLByAppendingAndEncodingQueryParameter:@"p" andValue:query];
    }
    
    return url;
}

- (NSURL *)appendKeys:(NSArray *)keys
                query:(NSString *)searchString
   serverSideFunction:(CMServerFunction *)function
        pagingOptions:(CMPagingDescriptor *)paging
       sortingOptions:(CMSortDescriptor *)sorting
                toURL:(NSURL *)theUrl
      extraParameters:(NSDictionary *)params {
    
    NSAssert(keys == nil || searchString == nil, @"When constructing CM URLs, 'keys' and 'searchString' are mutually exclusive");
    
    NSMutableArray *queryComponents = [NSMutableArray array];
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
    if (sorting) {
        [queryComponents addObject:[sorting stringRepresentation]];
    }
    if (params) {
        for(id key in params) {
            [queryComponents addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
        }
    }
    
    return [theUrl URLByAppendingAndEncodingQuery:[queryComponents componentsJoinedByString:@"&"]];
}

@end
