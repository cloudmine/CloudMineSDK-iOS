//
//  CMWebService.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <YAJLiOS/YAJL.h>

#import "SPLowVerbosity.h"
#import "NSData+Base64.h"

#import "CMWebService.h"
#import "CMAPICredentials.h"
#import "CMUser.h"
#import "CMServerFunction.h"
#import "CMPagingDescriptor.h"
#import "CMSortDescriptor.h"
#import "CMActiveUser.h"
#import "NSURL+QueryParameterAdditions.h"

#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"
#import "CMObjectSerialization.h"

#define CM_APIKEY_HEADER @"X-CloudMine-ApiKey"
#define CM_SESSIONTOKEN_HEADER @"X-CloudMine-SessionToken"

static __strong NSSet *_validHTTPVerbs = nil;
typedef CMUserAccountResult (^_CMWebServiceAccountResponseCodeMapper)(NSUInteger httpResponseCode);


@interface CMWebService ()
@property (nonatomic, strong) NSString *apiUrl;
- (NSURL *)constructTextUrlAtUserLevel:(BOOL)atUserLevel withKeys:(NSArray *)keys query:(NSString *)searchString pagingOptions:(CMPagingDescriptor *)paging sortingOptions:(CMSortDescriptor *)sorting withServerSideFunction:(CMServerFunction *)function extraParameters:(NSDictionary *)params;
- (NSURL *)constructBinaryUrlAtUserLevel:(BOOL)atUserLevel withKey:(NSString *)key withServerSideFunction:(CMServerFunction *)function extraParameters:(NSDictionary *)params;
- (NSURL *)constructDataUrlAtUserLevel:(BOOL)atUserLevel withKeys:(NSArray *)keys withServerSideFunction:(CMServerFunction *)function extraParameters:(NSDictionary *)params;
- (NSMutableURLRequest *)constructHTTPRequestWithVerb:(NSString *)verb URL:(NSURL *)url appSecret:(NSString *)appSecret binaryData:(BOOL)isForBinaryData user:(CMUser *)user;
- (void)executeUserAccountRequest:(NSURLRequest *)request codeMapper:(_CMWebServiceAccountResponseCodeMapper)codeMapper callback:(CMWebServiceUserAccountOperationCallback)callback;
- (void)executeRequest:(NSURLRequest *)request successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (void)executeBinaryDataFetchRequest:(NSURLRequest *)request successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler  errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (void)executeBinaryDataUploadRequest:(NSURLRequest *)request successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;
- (NSURL *)constructAccountUrlWithUserIdentifier:(NSString *)userId query:(NSString *)query;
- (NSURL *)appendKeys:(NSArray *)keys query:(NSString *)queryString serverSideFunction:(CMServerFunction *)function pagingOptions:(CMPagingDescriptor *)paging sortingOptions:(CMSortDescriptor *)sorting toURL:(NSURL *)theUrl extraParameters:(NSDictionary *)params;
@end


@implementation CMWebService
@synthesize networkQueue;
@synthesize apiUrl;

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
        _validHTTPVerbs = $set(@"GET", @"POST", @"PUT", @"DELETE");
    }

    if (self = [super init]) {
        self.networkQueue = [[NSOperationQueue alloc] init];
        self.apiUrl = CM_BASE_URL;

        _appSecret = appSecret;
        _appIdentifier = appIdentifier;
    }
    return self;
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
    [request setHTTPBody:[[data yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
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
    [request setHTTPBody:[[data yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
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
                                                                                URLByAppendingQueryString:@"all=true"]
                                                          appSecret:_appSecret
                                                      binaryData:NO
                                                            user:user];
    [self executeRequest:request successHandler:successHandler errorHandler:errorHandler];
}

#pragma mark - User account management

- (void)loginUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);

    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/login", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];

    // Add Basic Auth header manually
    NSData *credentialData = [[NSString stringWithFormat:@"%@:%@", user.userId, user.password] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *basicAuthValue = [NSString stringWithFormat:@"Basic %@", [credentialData base64EncodedString]];
    [request setValue:basicAuthValue forHTTPHeaderField:@"Authorization"];

    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode) {
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
    }
                           callback:callback];
}

- (void)logoutUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    NSAssert(user.isLoggedIn, @"Cannot logout a user that hasn't been logged in.");

    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/login", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];
    [request setValue:user.token forHTTPHeaderField:CM_SESSIONTOKEN_HEADER];

    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode) {
        switch (httpResponseCode) {
            case 200:
                return CMUserAccountLogoutSucceeded;
            case 404:
                return CMUserAccountOperationFailedUnknownAccount;
            default:
                return CMUserAccountUnknownResult;
        }
    }
                           callback:callback];
}

- (void)createAccountWithUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    NSAssert(user.userId != nil && user.password != nil, @"Cannot create an account from a user that doesn't have an ID or password set.");

    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/create", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];

    // The username and password of this account are supplied in the request body.
    NSMutableDictionary *payload = $mdict(@"credentials", $dict(@"email", user.userId, @"password", user.password));

    // Extract other profile fields from the user by serializing it to JSON and removing the "token" and "tokenExpiration" fields (which don't
    // need to be sent over the wire).
    NSMutableDictionary *serializedUser = [[[(NSDictionary *)[CMObjectEncoder encodeObjects:$array(user)] allValues] objectAtIndex:0] mutableCopy];
    [serializedUser removeObjectsForKeys:$array(@"token", @"tokenExpiration")];
    if ([serializedUser count] > 0) {
        [payload setObject:serializedUser forKey:@"profile"];
    }

    [request setHTTPBody:[[payload yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];

    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode) {
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
    }
                           callback:callback];
}

- (void)changePasswordForUser:(CMUser *)user oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword callback:(CMWebServiceUserAccountOperationCallback)callback {

    NSParameterAssert(user);
    NSParameterAssert(oldPassword);
    NSParameterAssert(newPassword);
    NSAssert(user.userId, @"Cannot change the password of a user that doesn't have a user id set.");

    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/password/change", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];

    // This API endpoint doesn't use a session token for security purposes. The user must supply their old password
    // explicitly in addition to their new password.
    NSData *credentialData = [[NSString stringWithFormat:@"%@:%@", user.userId, user.password] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *basicAuthValue = [NSString stringWithFormat:@"Basic %@", [credentialData base64EncodedString]];
    [request setValue:basicAuthValue forHTTPHeaderField:@"Authorization"];

    NSDictionary *payload = $dict(@"password", newPassword);
    [request setHTTPBody:[[payload yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];

    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode) {
        switch (httpResponseCode) {
            case 200:
                return CMUserAccountPasswordChangeSucceeded;
            case 401:
                return CMUserAccountPasswordChangeFailedInvalidCredentials;
            case 404:
                return CMUserAccountOperationFailedUnknownAccount;
            default:
                return CMUserAccountUnknownResult;
        }
    }
                           callback:callback];
}

- (void)resetForgottenPasswordForUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    NSAssert(user.userId, @"Cannot reset the password of a user that doesn't have a user id set.");

    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/password/reset", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];

    NSDictionary *payload = $dict(@"email", user.userId);
    [request setHTTPBody:[[payload yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];

    [self executeUserAccountActionRequest:request codeMapper:^CMUserAccountResult(NSUInteger httpResponseCode) {
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
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                             URL:[self constructAccountUrlWithUserIdentifier:nil query:nil]
                                                       appSecret:_appSecret
                                                      binaryData:NO
                                                            user:nil];
    [self executeUserProfileFetchRequest:request callback:callback];

}

- (void)getUserProfileWithIdentifier:(NSString *)identifier
                            callback:(CMWebServiceUserFetchSuccessCallback)callback {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"GET"
                                                             URL:[self constructAccountUrlWithUserIdentifier:identifier query:nil]
                                                       appSecret:_appSecret
                                                      binaryData:NO
                                                            user:nil];
    [self executeUserProfileFetchRequest:request callback:callback];
}

- (void)searchUsers:(NSString *)query callback:(CMWebServiceUserFetchSuccessCallback)callback {
    ASIHTTPRequest *request = [self constructHTTPRequestWithVerb:@"GET"
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
    [request addRequestHeader:@"Content-type" value:@"application/json"];

    __unsafe_unretained ASIHTTPRequest *blockRequest = request;
    void (^responseBlock)() = ^{
        NSDictionary *responseBody = [NSDictionary dictionary];
        if (blockRequest.responseString != nil) {
            NSError *parseErr = nil;
            NSDictionary *parsedResponseBody = [blockRequest.responseString yajl_JSON:&parseErr];
            if (!parseErr && parsedResponseBody) {
                responseBody = parsedResponseBody;
            }
        }

        if (callback != nil) {
            callback([responseBody objectForKey:@"success"], [responseBody objectForKey:@"errors"], $num([[responseBody objectForKey:@"success"] count]));
        }
    };

    [request setCompletionBlock:responseBlock];
    [request setFailedBlock:responseBlock];

    [self.networkQueue addOperation:request];
    [self.networkQueue go];
}

- (void)executeUserAccountActionRequest:(NSMutableURLRequest *)request
                             codeMapper:(_CMWebServiceAccountResponseCodeMapper)codeMapper
                               callback:(CMWebServiceUserAccountOperationCallback)callback {

    // TODO: Let this switch between MsgPack and GZIP'd JSON.
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    void (^responseBlock)() = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        CMUserAccountResult resultCode = codeMapper([response statusCode]);
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (resultCode == CMUserAccountUnknownResult) {
            NSLog(@"Unexpected response received from server during user account creation. Code %d, body: %@.", [response statusCode], responseString);
        }

        NSDictionary *responseBody = [NSDictionary dictionary];
        if (responseString != nil) {
            NSError *parseErr = nil;
            NSDictionary *parsedResponseBody = [responseString yajl_JSON:&parseErr];
            if (!parseErr && parsedResponseBody) {
                responseBody = parsedResponseBody;
            }
        }

        if (callback != nil) {
            callback(resultCode, responseBody);
        }
    };

    [NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:responseBlock];
}

- (void)executeRequest:(NSURLRequest *)request
        successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
          errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {

    void (^responseBlock)() = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
        if ([response statusCode] == 400 || [response statusCode] == 500) {
            NSDictionary *results = [responseString yajl_JSON];
            NSString *message = [results objectForKey:@"error"];
            error = $makeErr(@"CloudMine", 500, message);
        }

        if (error) {
            if (errorHandler != nil) {
                errorHandler(error);
            }
            return;
        }

        NSDictionary *results = [responseString yajl_JSON];
        
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
            successHandler(successes, errors, meta, snippetResult, count, [response allHeaderFields]);
        }
    };


    [NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:responseBlock];
}

- (void)executeBinaryDataFetchRequest:(NSURLRequest *)request
        successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler
          errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {

    void (^responseBlock)() = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {

        if ([response statusCode] == 200) {
            if (successHandler != nil) {
                successHandler(data, [[response allHeaderFields] objectForKey:@"Content-Type"], [response allHeaderFields]);
            }
        } else {
            if (errorHandler != nil) {
                NSError *err = $makeErr(@"CloudMine", [response statusCode], @"Something went wrong!"); // TODO: Obtain user readable status code message
                errorHandler(err);
            }
        }
    };

    [NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:responseBlock];
}

- (void)executeBinaryDataUploadRequest:(NSURLRequest *)request
                       successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler
                         errorHandler:(CMWebServiceFetchFailureCallback)errorHandler {

    void (^responseBlock)() = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if (errorHandler != nil) {
                errorHandler(error);
            }
            return;
        }
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *results = [responseString yajl_JSON];        
        id snippetResult = nil;
        NSString *key = [results objectForKey:@"key"];

        if (results) {
            snippetResult = [results objectForKey:@"result"];
            if (!snippetResult)
                snippetResult = [NSDictionary dictionary];
        }
        
        if (successHandler != nil) {
            successHandler([response statusCode] == 201 ? CMFileCreated : CMFileUpdated, key, snippetResult, [response allHeaderFields]);
        }
    };

    [NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:responseBlock];
}

#pragma - Request construction

- (NSURLRequest *)constructHTTPRequestWithVerb:(NSString *)verb
                                             URL:(NSURL *)url
                                          appSecret:(NSString *)appSecret
                                      binaryData:(BOOL)isForBinaryData
                                            user:(CMUser *)user {
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

    // Add user agent and user tracking headers
    [request setValue:[NSString stringWithFormat:@"CM-iOS/%@", CM_VERSION] forHTTPHeaderField:@"X-CloudMine-Agent"];
    [request setValue:[[CMActiveUser currentActiveUser] identifier] forHTTPHeaderField:@"X-CloudMine-UT"];

    #ifdef DEBUG
        NSLog(@"Constructed CloudMine URL: %@\nHeaders:%@", [request URL], [request allHTTPHeaderFields]);
    #endif

    return [request copy];
}

#pragma mark - General URL construction

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
        url = [url URLByAppendingQueryString:[NSString stringWithFormat:@"p=%@", query]];
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
    if (sorting) {
        [queryComponents addObject:[sorting stringRepresentation]];
    }
    if (params) {
        for(id key in params) {
            [queryComponents addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
        }
    }
    return [theUrl URLByAppendingQueryString:[queryComponents componentsJoinedByString:@"&"]];
}

@end
