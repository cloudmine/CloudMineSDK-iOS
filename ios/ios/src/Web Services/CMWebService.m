//
//  CMWebService.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <AFNetworking/AFNetworking.h>
#import <YAJLiOS/YAJL.h>

#import "SPLowVerbosity.h"

#import "CMWebService.h"
#import "CMStore.h"
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
typedef CMUserAccountResult (^_CMWebServiceAccountResponseCodeMapper)(NSUInteger httpResponseCode, NSError *error);

NSString * const CMErrorDomain = @"CMErrorDomain";
NSString * const NSURLErrorKey = @"NSURLErrorKey";
NSString * const YAJLErrorKey = @"YAJLErrorKey";

@interface CMWebService () {
    NSMutableDictionary *_responseTimes;
}
@property (nonatomic, strong) NSString *apiUrl;
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
@end


@implementation CMWebService
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

    if ((self = [super initWithBaseURL:nil])) {
        self.apiUrl = CM_BASE_URL;

        _appSecret = appSecret;
        _appIdentifier = appIdentifier;
        _responseTimes = [NSMutableDictionary dictionary];
        
        // Enable activity indicator in status bar
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
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
    [request setHTTPBody:[[data yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
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
    [request setHTTPBody:[[acl yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
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

#pragma mark - User account management

- (void)loginUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);

    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/login", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];

    CFHTTPMessageRef dummyRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), (__bridge CFURLRef)[request URL], kCFHTTPVersion1_1);
    CFHTTPMessageAddAuthentication(dummyRequest, nil, (__bridge CFStringRef)user.userId, (__bridge CFStringRef)user.password, kCFHTTPAuthenticationSchemeBasic, FALSE);
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
    NSAssert(user.userId != nil && user.password != nil, @"CloudMine *** User creation failed because the user object doesn't have a user ID or password set.");

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

- (void)saveUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);

    if (user.isCreatedRemotely) {
        // The user has already been saved, so just update the profile. In order for this to work, the user must be logged in.

        void (^save)() = ^{
            NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/%@", _appIdentifier, user.objectId]];
            NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:user];
            NSMutableDictionary *payload = [[[CMObjectEncoder encodeObjects:$set(user)] objectForKey:user.objectId] mutableCopy]; // Don't need the outer object wrapping it like with objects
            [payload removeObjectsForKeys:$array(@"token", @"tokenExpiration")];
            [request setHTTPBody:[[payload yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
            
            AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseString = [operation responseString];
                
                // Parse responsibly. If error is not handled, it will crash the application!
                NSError *parseErr = nil;
                NSDictionary *results = [NSDictionary dictionary];
                if (responseString != nil) {
                    NSDictionary *parsedResults = [responseString yajl_JSON:&parseErr];
                    if (!parseErr && parsedResults) {
                        results = parsedResults;
                    }
                }

                // Handle any service errors, or report success
                if ([[operation response] statusCode] == 200 && [[results objectForKey:@"errors"] count] == 0) {
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
            
            [self enqueueHTTPRequestOperation:requestOperation];
        };

        if (!user.isLoggedIn) {
            if (!user.userId && !user.password) {
                NSLog(@"CloudMine *** Cannot update a user profile when the user is not logged in and userId and password are not both set.");
                callback(CMUserAccountLoginFailedIncorrectCredentials, [NSDictionary dictionary]);
            }

            // User must be logged in for this to work, so try logging them in.
            [user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                if (CMUserAccountOperationFailed(resultCode)) {
                    // If login failed, pass the error through.
                    callback(resultCode, [NSDictionary dictionary]);
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
    NSAssert(user.userId, @"CloudMine *** User password change failed because the user object doesn't have a user ID set.");

    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/password/change", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];

    // This API endpoint doesn't use a session token for security purposes. The user must supply their old password
    // explicitly in addition to their new password.
    CFHTTPMessageRef dummyRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), (__bridge CFURLRef)[request URL], kCFHTTPVersion1_1);
    CFHTTPMessageAddAuthentication(dummyRequest, nil, (__bridge CFStringRef)user.userId, (__bridge CFStringRef)oldPassword, kCFHTTPAuthenticationSchemeBasic, FALSE);
    NSString *basicAuthValue = (__bridge_transfer NSString *)CFHTTPMessageCopyHeaderFieldValue(dummyRequest, CFSTR("Authorization"));
    [request setValue:basicAuthValue forHTTPHeaderField:@"Authorization"];
    CFRelease(dummyRequest);

    NSDictionary *payload = $dict(@"password", newPassword);
    [request setHTTPBody:[[payload yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];

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
                return CMUserAccountPasswordChangeSucceeded;
            case 401:
                return CMUserAccountPasswordChangeFailedInvalidCredentials;
            case 404:
                return CMUserAccountOperationFailedUnknownAccount;
            default:
                return CMUserAccountUnknownResult;
        }
    } callback:^(CMUserAccountResult resultCode, NSDictionary *messages) {
        switch (resultCode) {
            case CMUserAccountPasswordChangeFailedInvalidCredentials:
                NSLog(@"CloudMine *** User password change failed because the credentials provided were incorrect");
                break;
            case CMUserAccountOperationFailedUnknownAccount:
                NSLog(@"CloudMine *** User password change failed because the application does not exist");
                break;
            default:
                break;
        }
        callback(resultCode, messages);
    }];
}

- (void)resetForgottenPasswordForUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback {
    NSParameterAssert(user);
    NSAssert(user.userId, @"CloudMine *** User password reset failed because the user object doesn't have a user ID set.");

    NSURL *url = [NSURL URLWithString:[self.apiUrl stringByAppendingFormat:@"/app/%@/account/password/reset", _appIdentifier]];
    NSMutableURLRequest *request = [self constructHTTPRequestWithVerb:@"POST" URL:url appSecret:_appSecret binaryData:NO user:nil];

    NSDictionary *payload = $dict(@"email", user.userId);
    [request setHTTPBody:[[payload yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];

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
            NSDictionary *parsedResponseBody = [responseString yajl_JSON:&parseErr];
            if (!parseErr && parsedResponseBody) {
                responseBody = parsedResponseBody;
            }
        }

        if (callback != nil) {
            void (^block)() = ^{ callback([responseBody objectForKey:@"success"], [responseBody objectForKey:@"errors"], $num([[responseBody objectForKey:@"success"] count])); };
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
            NSDictionary *parsedResponseBody = [responseString yajl_JSON:&parseErr];
            if (!parseErr && parsedResponseBody) {
                responseBody = parsedResponseBody;
            }
        }

        if (resultCode == CMUserAccountUnknownResult) {
            NSLog(@"CloudMine *** Unexpected response received from server during user account operation. (%@) (Code %d) Body: %@", [parseErr localizedDescription], [operation.response statusCode], responseString);
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
        
        NSString *responseString = [operation responseString];
        
        NSError *parseError;
        NSDictionary *results = [responseString yajl_JSON:&parseError];
        
        if ([[parseError domain] isEqualToString:YAJLErrorDomain]) {
            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response received from the server was malformed.", NSLocalizedDescriptionKey, parseError, YAJLErrorKey, nil]];
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
        
        NSString *responseString = [operation responseString];
        
        NSError *parseError;
        NSDictionary *results = [responseString yajl_JSON:&parseError];
        
        if ([[parseError domain] isEqualToString:YAJLErrorDomain]) {
            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response received from the server was malformed.", NSLocalizedDescriptionKey, parseError, YAJLErrorKey, nil]];
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
        
        NSString *responseString = [operation responseString];
        
        NSError *parseError;
        NSDictionary *results = [responseString yajl_JSON:&parseError];
        
        if ([[parseError domain] isEqualToString:YAJLErrorDomain]) {
            NSError *error = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidResponse userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response received from the server was malformed.", NSLocalizedDescriptionKey, parseError, YAJLErrorKey, nil]];
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

- (void)performBlock:(void (^)())block {
    block();
}

#pragma - Request construction

- (NSMutableURLRequest *)constructHTTPRequestWithVerb:(NSString *)verb
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

    // Add response times to user token string
    NSMutableArray *times = [NSMutableArray array];
    [_responseTimes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
        [times addObject:[NSString stringWithFormat:@"%@:%@", key, [obj stringValue]]];
    }];
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

#pragma mark - General URL construction

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
