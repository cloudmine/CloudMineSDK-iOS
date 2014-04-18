//
//  CMWebService.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import "AFHTTPClient.h"

#import "CMFileUploadResult.h"
#import "CMDeviceTokenResult.h"
#import "CMUserAccountResult.h"
#import "CMSocialLoginViewController.h"
#import "CMChannelResponse.h"
#import "CMViewChannelsResponse.h"

@class CMUser;
@class CMServerFunction;
@class CMPagingDescriptor;
@class CMSortDescriptor;

typedef void (^CMWebServiceGenericRequestCallback)(id parsedBody, NSUInteger httpCode, NSDictionary *headers);

typedef void (^CMWebServiceErorCallack)(id responseBody, NSUInteger httpCode, NSDictionary *headers, NSError *error, NSDictionary *errorInfo );


/**
 * Callback block signature for all operations on <tt>CMWebService</tt> that fetch objects
 * from the CloudMine servers. These blocks return <tt>void</tt> and take a dictionary of results,
 * a dictionary of errors, a dictionary of metadata, and a dynamic snippet result as arguments.
 * These map directly with the CloudMine API response format.
 */
typedef void (^CMWebServiceObjectFetchSuccessCallback)(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count, NSDictionary *headers);

/**
 * Callback block signature for <b>all</b> operations on <tt>CMWebService</tt> that can fail. These are general
 * errors that cause the entire call to fail, not key-specific errors (which are reported instead in
 * the <tt>errors</tt> dictionary in the <tt>CMWebServiceObjectFetchSuccessCallback</tt> callback block).
 * The block returns <tt>void</tt> and takes an <tt>NSError</tt> describing the error as an argument.
 */
typedef void (^CMWebServiceFetchFailureCallback)(NSError *error);

/**
 * Callback block signature for all operations on <tt>CMWebService</tt> that upload binary files to
 * the CloudMine servers. These blocks return <tt>void</tt> and take a <tt>CMFileUploadResult</tt>, the key
 * of the new file, and a dynamic snippet result as arguments to indicate the final result of the upload operation.
 */
typedef void (^CMWebServiceFileUploadSuccessCallback)(CMFileUploadResult result, NSString *fileKey, id snippetResult, NSDictionary *headers);

/**
 * Callback block signature for operations on <tt>CMWebService</tt> that directly execute a server-side code snippet on the CloudMine servers.
 * These blocks return <tt>void</tt> and take the snippet result (the type of which is determined by the type of data you use inside your exit() call 
 * in your server-side JavaScript code or what you return from the main method in your server-side Java code) and all the headers of the response.
 */
typedef void (^CMWebServiceSnippetRunSuccessCallback)(id snippetResult, NSDictionary *headers);

typedef CMWebServiceFetchFailureCallback CMWebServiceSnippetRunFailureCallback;

/**
 * Callback block signature for all operations on <tt>CMWebService</tt> that download binary files from
 * the CloudMine servers. These blocks return <tt>void</tt> and take an <tt>NSData</tt> instance that contains
 * the raw data for the file as well as a string with the content type of the file returned from the server.
 */
typedef void (^CMWebServiceFileFetchSuccessCallback)(NSData *data, NSString *contentType, NSDictionary *headers);

/**
 * Callback block signature for all operations on <tt>CMWebService</tt> and <tt>CMUser</tt> that involve the management
 * of user accounts and user sessions. These blocks return <tt>void</tt> and take a <tt>CMUserAccountResult</tt> code
 * that represents the result of the operation as well as an <tt>NSDictionary</tt> containing the dictionary representation
 * of the response body from the server.
 */
typedef void (^CMWebServiceUserAccountOperationCallback)(CMUserAccountResult result, NSDictionary *responseBody);

/**
 * Callback block signature for all operations that return a list of users for the current app
 * from the CloudMine servers. These blocks return <tt>void</tt> and take a dictionary of results,
 * a dictionary of errors, and the total number of users returned as arguments.
 * The contents of the former two map directly to the CloudMine API response format.
 */
typedef void (^CMWebServiceUserFetchSuccessCallback)(NSDictionary *results, NSDictionary *errors, NSNumber *count);

typedef void (^CMWebServicesSocialQuerySuccessCallback)(NSString *results, NSDictionary *headers);

typedef void (^CMWebServiceResultCallback)(id responseBody, NSError *errors, NSUInteger httpCode);

/**
 * Base class for all classes concerned with the communication between the client device and the CloudMine
 * web services.
 */
@interface CMWebService : AFHTTPClient <CMSocialLoginViewControllerDelegate> {
    NSString *_appSecret;
    NSString *_appIdentifier;
}

+ (CMWebService *)sharedWebService;


/**
 * Default initializer for the web service connector. You <strong>must</strong> have already configured the
 * <tt>CMUserCredentials</tt> singleton or an exception will be thrown.
 * The baseURL will be to CloudMine, or whatever is last configured in CMAPICredentials.
 *
 * @throws NSInternalInconsistencyException <tt>CMUserCredentials</tt> has not been configured.
 */
- (id)init;

/**
 * Default initializer for the web service connector. You <strong>must</strong> have already configured the
 * <tt>CMUserCredentials</tt> singleton or an exception will be thrown.
 * The baseURL will be to CloudMine, or whatever is last configured in CMAPICredentials.
 *
 * @param url The base URL you want to point this web service to. Defaults to CloudMine.
 * @throws NSInternalInconsistencyException <tt>CMUserCredentials</tt> has not been configured.
 */
- (id)initWithBaseURL:(NSURL *)url;

/**
 * Initializes an instance of a web service connector with the given API key and secret app key. The baseURL for
 * this WebService will be to CloudMine, or whatever is last configured in CMAPICredentials.
 * 
 * @param appSecret The App Secret for your application
 * @param appIdentifier The App ID for your application
 */
- (id)initWithAppSecret:(NSString *)appSecret appIdentifier:(NSString *)appIdentifier;

/**
 * Initializes an instance of the Web Service with the App ID, and secret key, and base URL This can be useful
 * if you are pointing your CloudMine SDK to a different place than the default. All parameters are required.
 *
 * @param appSecret The App Secret for your application
 * @param appIdentifier The App ID for your application
 * @param url The Base URL you want this Web Service to point to.
 */
- (id)initWithAppSecret:(NSString *)appSecret appIdentifier:(NSString *)appIdentifier baseURL:(NSURL *)url;

/**
 * Asynchronously retrieve all ACLs associated with the named user. On completion, the <tt>successHandler</tt> block
 * will be called with a dictionary of the ACLs retrieved.
 *
 * @param user The user whose ACLs to fetch.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)getACLsForUser:(CMUser *)user
        successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
          errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously retrieve objects for the named user-level keys. On completion, the <tt>successHandler</tt> block
 * will be called with a dictionary of the objects retrieved as well as a dictionary of the key-related errors returned from the server.
 *
 * @param keys The keys to fetch.
 * @param function The server-side code snippet and related options to execute with this request, or nil if none.
 * @param user The user whose data to fetch. If nil, fetches app-level objects.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)getValuesForKeys:(NSArray *)keys
      serverSideFunction:(CMServerFunction *)function
           pagingOptions:(CMPagingDescriptor *)paging
          sortingOptions:(CMSortDescriptor *)sorting
                    user:(CMUser *)user
         extraParameters:(NSDictionary *)params
          successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

- (void)searchValuesFor:(NSString *)searchQuery
     serverSideFunction:(CMServerFunction *)function
          pagingOptions:(CMPagingDescriptor *)paging
         sortingOptions:(CMSortDescriptor *)sorting
                   user:(CMUser *)user
        extraParameters:(NSDictionary *)params
         successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
           errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously search all ACLs associated with the user, using the specified query. On completion, the <tt>successHandler</tt> block
 * will be called with a dictionary of the ACLs retrieved.
 *
 * @param query This is the same syntax as defined at https://cloudmine.me/docs/api#query_syntax and used by <tt>CMStore</tt>'s search methods.
 * @param user The user whose ACLs to query.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)searchACLs:(NSString *)query
              user:(CMUser *)user
    successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
      errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously retrieve a binary file for the named user-leve key. On completion, the <tt>successHandler</tt> block
 * will be called with the raw data from the server.
 *
 * @param keys The key of the binary file to fetch.
 * @param user The user whose data to fetch. If nil, fetches app-level objects.
 * @param successHandler The block to be called when the file has been fully downloaded.
 * @param errorHandler The block to be called if the request failed.
 */
- (void)getBinaryDataNamed:(NSString *)key
        serverSideFunction:(CMServerFunction *)function
                      user:(CMUser *)user
           extraParameters:(NSDictionary *)params
            successHandler:(CMWebServiceFileFetchSuccessCallback)successHandler
              errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously update one or more objects for the user-level keys included in <tt>data</tt>. On completion, the <tt>successHandler</tt>
 * block will be called with a dictionary of the keys of the objects that were created and updated as well as a dictionary of the
 * key-related errors returned from the server.
 *
 * @param data A dictionary mapping top-level keys to the values to be used to update the object.
 * @param function The server-side code snippet and related options to execute with this request, or nil if none.
 * @param user The user whose data to write. If nil, writes as app-level objects.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)updateValuesFromDictionary:(NSDictionary *)data
                serverSideFunction:(CMServerFunction *)function
                              user:(CMUser *)user
                   extraParameters:(NSDictionary *)params
                    successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
                      errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously update the specified ACL. On completion, the <tt>successHandler</tt> block will be called with a dictionary containing
 * the object updated.
 *
 * @param acl This is a dictionary containing the attributes of the ACL object to update, as serialized by <tt>CMObjectEncoder</tt>.
 * @param user The user to whom the ACL is associated.
 * @param successHandler The block to be called when a response has been received.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)updateACL:(NSDictionary *)acl
             user:(CMUser *)user
   successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
     errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously upload the raw binary data contained in <tt>data</tt> with an optional MIME type as a user-level object.
 * On completion, the <tt>successHandler</tt> block will be called with a status code indicating
 * whether a file with the given key previously existed on the server or had to be created new.
 *
 * @param data The raw binary data of the file to upload.
 * @param key The unique name of this file. If this is nil, a key will be generated on the server.
 * @param mimeType The MIME type of this file. When later fetched, this MIME type will be used in the Content-Type header. If <tt>nil</tt>, defaults to <tt>application/octet-stream</tt>.
 * @param user The user whose data to write. If nil, writes as app-level objects.
 * @param successHandler The block to be called when the file has finished uploading. The <tt>result</tt> parameter indicates whether the file was new to the server or not.
 * @param errorHandler The block to be called if the request failed.
 */
- (void)uploadBinaryData:(NSData *)data
      serverSideFunction:(CMServerFunction *)function
                   named:(NSString *)key
              ofMimeType:(NSString *)mimeType
                    user:(CMUser *)user
         extraParameters:(NSDictionary *)params
          successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously upload the raw binary data contained in the file stored at the path specified by <tt>path</tt> with an optional
 * MIME type as an user-level object. Unlike its cousin method <tt>uploadBinaryData:</tt>, this method streams the contents of
 * the file directly from the filesystem without first loading it into RAM, making it perfect for uploading large files
 * on the filesystem efficiently.
 *
 * On completion, the <tt>successHandler</tt> block will be called with a status code indicating
 * whether a file with the given key previously existed on the server or had to be created new.
 *
 * @param path The path to the file to upload.
 * @param key The unique name of this file.
 * @param mimeType The MIME type of this file. When later fetched, this MIME type will be used in the Content-Type header. If <tt>nil</tt>, defaults to <tt>application/octet-stream</tt>.
 * @param user The user whose data to write. If nil, writes as app-level objects.
 * @param successHandler The block to be called when the file has finished uploading. The <tt>result</tt> parameter indicates whether the file was new to the server or not.
 * @param errorHandler The block to be called if the request failed.
 */
- (void)uploadFileAtPath:(NSString *)path
      serverSideFunction:(CMServerFunction *)function
                   named:(NSString *)key
              ofMimeType:(NSString *)mimeType
                    user:(CMUser *)user
         extraParameters:(NSDictionary *)params
          successHandler:(CMWebServiceFileUploadSuccessCallback)successHandler
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously create or replace one or more objects for the values of the user-level keys included in <tt>data</tt>. On completion, the <tt>successHandler</tt>
 * block will be called with a dictionary of the keys of the objects that were created and replaced as well as a dictionary of the
 * key-related errors returned from the server.
 *
 * Note that if the key already exists server-side, this method will fully replace its value. For updating via merge, see the <tt>updateValuesFromDictionary</tt> methods.
 *
 * @see updateValuesFromDictionary:serverSideFunction:user:successHandler:errorHandler:
 *
 * @param data A dictionary mapping top-level keys to the values to be used to update the object.
 * @param function The server-side code snippet and related options to execute with this request, or nil if none.
 * @param user The user whose data to write. If nil, writes as app-level objects.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)setValuesFromDictionary:(NSDictionary *)data
             serverSideFunction:(CMServerFunction *)function
                           user:(CMUser *)user
                extraParameters:(NSDictionary *)params
                 successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
                   errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously delete objects for the named user-level keys. On completion, the <tt>successHandler</tt> block
 * will be called.
 *
 * For the sake of consistency, <tt>results</tt> and <tt>errors</tt> will be sent to the callback like with all the other methods in this class,
 * however they will <strong>always</strong> be empty.
 *
 * @param keys The keys to delete. If <tt>nil</tt> or an empty array, <strong>all of this user's objects will be deleted.</strong>
 * @param user The user whose data to delete. If nil, deletes app-level objects.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)deleteValuesForKeys:(NSArray *)keys
         serverSideFunction:(CMServerFunction *)function
                       user:(CMUser *)user
            extraParameters:(NSDictionary *)params
             successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
               errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously delete the ACL with the specified key, associated with the specified user. On completion, the <tt>successHandler</tt> block will be called
 * with a dictionary containing the status of the deletion.
 *
 * @param key The key of the ACL that will be deleted.
 * @param user The user to whom the ACL is associated.
 * @param successHandler The block to be called when a response has been received.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)deleteACLWithKey:(NSString *)key
                    user:(CMUser *)user
          successHandler:(CMWebServiceObjectFetchSuccessCallback)successHandler
            errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously login a user and create a new session. On completion, the <tt>callback</tt> block will be called with
 * the result of the operation and the body of the response represented by an <tt>NSDictonary</tt>. See the CloudMine
 * documentation online for the possible contents of this dictionary.
 *
 * Possible result codes:
 * - <tt>CMUserAccountLoginSucceeded</tt>
 * - <tt>CMUserAccountLoginFailedIncorrectCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param user The user to log in.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see https://cloudmine.me/docs/ios/reference#users_login
 */
- (void)loginUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback;

/**
 * Asynchronously logout a user and clear their session and session token. On completion, the <tt>callback</tt>
 * block will be called with the result of the operation and the body of the response represented by an <tt>NSDictonary</tt>.
 * See the CloudMine documentation online for the possible contents of this dictionary.
 *
 * Possible result codes:
 * - <tt>CMUserAccountLogoutSucceeded</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param user The user to log out.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see https://cloudmine.me/docs/ios/reference#users_logout
 */
- (void)logoutUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback;

/**
 * Asynchronously create a new account for the user on CloudMine. This must be done once for each user before they can login.
 * On completion, the <tt>callback</tt> block will be called with the result
 * of the operation and the body of the response represented by an <tt>NSDictonary</tt>.
 * See the CloudMine documentation online for the possible contents of this dictionary.
 *
 * Possible result codes:
 * - <tt>CMUserAccountCreateSucceeded</tt>
 * - <tt>CMUserAccountCreateFailedInvalidRequest</tt>
 * - <tt>CMUserAccountCreateFailedDuplicateAccount</tt>
 *
 * @param user The user who needs an account created.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see https://cloudmine.me/docs/ios/reference#users_create
 */
- (void)createAccountWithUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback;

/**
 * Initialize the social login service by calling the SocialLoginViewController (which contains only a webview)
 * 
 * @param user The user object that is attempting the login
 * @param service The social service to be logged into, @see CMSocialNetwork codes
 * @param viewController the current viewController in use when this method is called
 * @param params Any extra parameters you want passed in to the authentication request. This dictionary is parsed where each key value pair becomes "&key=value". We do not encode the URL after this, so any encoding will need to be done by the creator. This is a good place to put scope, for example: @{@"scope" : @"gist,repo"}
 * @param callback The block that will be called on completion of the operation
 * @see https://cloudmine.me/docs/api#users_social
 */
- (CMSocialLoginViewController *)loginWithSocial:(CMUser *)user
                                     withService:(NSString *)service
                                  viewController:(UIViewController *)viewController
                                          params:(NSDictionary *)params
                                        callback:(CMWebServiceUserAccountOperationCallback)callback;

/**
 * Asynchronously change the password for the given user. For security purposes, you must have the user enter his or her
 * old password and new password in order to perform this operation. This operation will succeed regardless of whether
 * the user's <tt>CMUser</tt> instance is logged in or not.
 * On completion, the <tt>callback</tt> block will be called with the result  of the operation and the body of the
 * response represented by an <tt>NSDictonary</tt>. See the CloudMine documentation online for the possible contents of this dictionary.
 *
 * If the user has forgotten his or her password, use <tt>resetForgottenPasswordForUser:callback:</tt> instead of this method.
 *
 * Possible result codes:
 * - <tt>CMUserAccountPasswordChangeSucceeded</tt>
 * - <tt>CMUserAccountPasswordChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param user The user whose password is being changed.
 * @param newPassword The new password to use.
 * @param oldPassword The user's old password.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see https://cloudmine.me/docs/ios/reference#users_pass_change
 */
- (void)changePasswordForUser:(CMUser *)user oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword callback:(CMWebServiceUserAccountOperationCallback)callback;



/**
 * <strong>DEPRECATED: </strong> This method is now deprecated. Use <tt>changeCredentialsForUser:password:newPassword:newUsername:newEmail:callback:</tt> instead.
 *
 * Asynchronously change the credentials for the given user. For security purposes, you must have the user enter his or her password
 * in order to perform this operation. This operation will succeed regardless of whether the user's <tt>CMUser</tt> instance
 * is logged in or not.
 * This method is useful when changing multiple fields for the user, and is the only method to change their username/userId. This
 * method is generally called from the <tt>CMUser</tt>.
 * On completion, the <tt>callback</tt> block will be called with the result  of the operation and the body of the
 * response represented by an <tt>NSDictonary</tt>. See the CloudMine documentation online for the possible contents of this dictionary.
 *
 * Possible result codes:
 * - <tt>CMUserAccountPasswordChangeSucceeded</tt>
 * - <tt>CMUserAccountUserIdChangeSucceeded</tt>
 * - <tt>CMUserAccountUsernameChangeSucceeded</tt>
 * - <tt>CMUserAccountCredentialsChangeSucceeded</tt> Used if more than one credential field was changed.
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateUserId</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateUsername</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateInfo</tt>
 * - <tt>CMUserAccountCredentialChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 * - <tt>CMUserAccountUnknownResult</tt>
 *
 * @param user The user who is having their credentials changed.
 * @param password The current password for the user.
 * @param newPassword Can be nil. The new password for the user.
 * @param newUsername Can be nil. The new username for the user.
 * @param newUserId Can be nil. THe new userId for the user. Must be in the form of an email.
 *
 * @see CMUserAccountResult
 */
- (void)changeCredentialsForUser:(CMUser *)user
                        password:(NSString *)password
                     newPassword:(NSString *)newPassword
                     newUsername:(NSString *)newUsername
                       newUserId:(NSString *)newUserId
                        callback:(CMWebServiceUserAccountOperationCallback)callback __attribute__((deprecated));

/**
 * Asynchronously change the credentials for the given user. For security purposes, you must have the user enter his or her password
 * in order to perform this operation. This operation will succeed regardless of whether the user's <tt>CMUser</tt> instance
 * is logged in or not.
 * This method is useful when changing multiple fields for the user, and is the only method to change their username/email. This
 * method is generally called from the <tt>CMUser</tt>.
 * On completion, the <tt>callback</tt> block will be called with the result  of the operation and the body of the
 * response represented by an <tt>NSDictonary</tt>. See the CloudMine documentation online for the possible contents of this dictionary.
 *
 * Possible result codes:
 * - <tt>CMUserAccountPasswordChangeSucceeded</tt>
 * - <tt>CMUserAccountEmailChangeSucceeded</tt>
 * - <tt>CMUserAccountUsernameChangeSucceeded</tt>
 * - <tt>CMUserAccountCredentialsChangeSucceeded</tt> Used if more than one credential field was changed.
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateEmail</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateUsername</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateInfo</tt>
 * - <tt>CMUserAccountCredentialChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 * - <tt>CMUserAccountUnknownResult</tt>
 *
 * @param user The user who is having their credentials changed.
 * @param password The current password for the user.
 * @param newPassword Can be nil. The new password for the user.
 * @param newUsername Can be nil. The new username for the user.
 * @param newUserId Can be nil. THe new userId for the user. Must be in the form of an email.
 *
 * @see CMUserAccountResult
 */
- (void)changeCredentialsForUser:(CMUser *)user
                        password:(NSString *)password
                     newPassword:(NSString *)newPassword
                     newUsername:(NSString *)newUsername
                        newEmail:(NSString *)newEmail
                        callback:(CMWebServiceUserAccountOperationCallback)callback;

/**
 * Asynchronously reset the password for the given user. This method is used to reset a user's password if
 * he or she forgot it. This method of course does not require the user to be logged in in order to function.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and the body of the
 * response represented by an <tt>NSDictonary</tt>. See the CloudMine documentation online for the possible contents of this dictionary.
 *
 * This method causes an email to be sent to the user with a link that allows them to reset their password from their browser.
 * Upon creating a new password, the user will be able to login with it via your app immediately.
 *
 * Possible result codes:
 * - <tt>CMUserAccountPasswordResetEmailSent</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param user The user who needs their password reset.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see https://cloudmine.me/docs/ios/reference#users_pass_reset
 */
- (void)resetForgottenPasswordForUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback;

/**
 * Asynchronously fetch all the users of this app. This will download the profiles of all the users of your app, and is useful for displaying
 * lists of people to share with or running analytics on your users yourself. On completion, the <tt>callback</tt> block
 * will be called with a dictionary of the objects retrieved as well as a dictionary of the key-related errors returned from the server.
 *
 * @param callback The block that will be called on completion of the operation.
 */
- (void)getAllUsersWithCallback:(CMWebServiceUserFetchSuccessCallback)callback;

/**
 * Asynchronously fetch a single user profile of a user of this app given its objectId. On completion, the <tt>callback</tt> block
 * will be called with a dictionary of the objects retrieved as well as a dictionary of the key-related errors returned from the server.
 *
 * @param identifier The objectId of the user profile to retrieve. You can access this via CMUser#objectId.
 * @param callback The block that will be called on completion of the operation.
 */
- (void)getUserProfileWithIdentifier:(NSString *)identifier callback:(CMWebServiceUserFetchSuccessCallback)callback;

/**
 * Asynchronously search all profiles of users of this app for matching fields. This will download the profiles of all matching users of your app,
 * and is useful for displaying and filtering lists of people to share with or running analytics on your users yourself. On completion, the <tt>callback</tt> block
 * will be called with a dictionary of the objects retrieved as well as a dictionary of the key-related errors returned from the server.
 *
 * @param query The search query to run against all user profiles. This is the same syntax as defined at https://cloudmine.me/docs/api#query_syntax and used by <tt>CMStore</tt>'s search methods.
 * @param callback The block that will be called on completion of the operation.
 */
- (void)searchUsers:(NSString *)query callback:(CMWebServiceUserFetchSuccessCallback)callback;

- (void)saveUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback;

/**
 * Asynchronously execute a snippet. On completion, the <tt>successHandler</tt> block will be called with the result of the snippet.
 *
 * @param snippetName The name of the server-side snippet to run.
 * @param params Any parameters that need to be passed to the snippet. Can be nil.
 * @param user Passed to the snippet if it operates on user-level objects. If nil, then the snippet will operate on app-level objects.
 * @param successHandler The block to be called when the snippet successfully executes.
 * @param errorHandler The block to be called if the request failed.
 */
- (void)runSnippet:(NSString *)snippetName withParams:(NSDictionary *)params user:(CMUser *)user successHandler:(CMWebServiceSnippetRunSuccessCallback)successHandler errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

- (void)runPOSTSnippet:(NSString *)snippetName withBody:(NSData *)body user:(CMUser *)user successHandler:(CMWebServiceSnippetRunSuccessCallback)successHandler errorHandler:(CMWebServiceSnippetRunFailureCallback)errorHandler;

/**
 * Asynchronously register the device token with CloudMine. On completion, the <tt>callback</tt> will be called with the result of the registration.
 *
 * @param user The user to which you want the token registered.
 * @param devToken Required, the token Apple has supplied for getting push notifications, this should be unaltered.
 * @param callback The callback called when the result is done.
 */
- (void)registerForPushNotificationsWithUser:(CMUser *)user token:(NSData *)devToken callback:(CMWebServiceDeviceTokenCallback)callback;

/**
 * Asynchronously unregister the device with CloudMine. The device should be registered already before calling this.
 *
 * @param user The user who has the token registered to it
 * @param callback The callback called when the request has finished.
 */
- (void)unRegisterForPushNotificationsWithUser:(CMUser *)user callback:(CMWebServiceDeviceTokenCallback)callback;

/**
 * Asynchronously subscribes this device to a named Channel. The device should be registered to receive push notificiations.
 *
 * @param channel The Push Channel to register this device too.
 * @param callback The CMWebServiceDeviceChannelCallback that will be called when the call is finished.
 */
- (void)subscribeThisDeviceToPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback;

/**
 * Asynchronously subscribes a device to a named Channel. The device should be registered to receive push notificiations.
 *
 * @param deviceID The deviceID that should be registered to the channel.
 * @param channel The Push Channel to register this device too.
 * @param callback The CMWebServiceDeviceChannelCallback that will be called when the call is finished.
 */
- (void)subscribeDevice:(NSString *)deviceID toPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback;

/**
 * Asynchronously subscribes the user to a named Channel. The user needs to be logged in.
 *
 * @param user The user who should be subscribed to the channel.
 * @param channel The Push Channel to register this device too.
 * @param callback The CMWebServiceDeviceChannelCallback that will be called when the call is finished.
 */
- (void)subscribeUser:(CMUser *)user toPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback;

/**
 * Asynchronously unsubscribes this device from a named Channel.
 *
 * @param channel The Push Channel to register this device too.
 * @param callback The CMWebServiceDeviceChannelCallback that will be called when the call is finished.
 */
- (void)unSubscribeThisDeviceFromPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback;

/**
 * Asynchronously unsubscribes a device from a named Channel. The device should be registered to receive push notificiations.
 *
 * @param deviceID The deviceID that should be registered to the channel.
 * @param channel The Push Channel to register this device too.
 * @param callback The CMWebServiceDeviceChannelCallback that will be called when the call is finished.
 */
- (void)unSubscribeDevice:(NSString *)deviceID fromPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback;

/**
 * Asynchronously unsubscribes the user from a named Channel. The user needs to be logged in.
 *
 * @param user The user who should be subscribed to the channel.
 * @param channel The Push Channel to register this device too.
 * @param callback The CMWebServiceDeviceChannelCallback that will be called when the call is finished.
 */
- (void)unSubscribeUser:(CMUser *)user fromPushChannel:(NSString *)channel callback:(CMWebServiceDeviceChannelCallback)callback;

/**
 * Asynchronously gets the channels this device is registered too.
 *
 * @param callback The CMViewChannelsRequestCallback that will be called when the call is finished.
 */
- (void)getChannelsForThisDeviceWithCallback:(CMViewChannelsRequestCallback)callback;

/**
 * Asynchronously gets the channels a device is registered too.
 *
 * @param deviceID The deviceID to query.
 * @param callback The CMViewChannelsRequestCallback that will be called when the call is finished.
 */
- (void)getChannelsForDevice:(NSString *)deviceID callback:(CMViewChannelsRequestCallback)callback;

/**
 * Asynchronously execute a request on the social network through the singly proxy.
 *
 * @param network The Network this request is targeting. @see CMSocialNetwork
 * @param verb the HTTP verb this request is calling.
 * @param base Can be nil, but probably shouldn't be most of the time. The base query for the request, before any "query" parameters. This does NOT include the hostname, or the version of the API. For example, "https://api.twitter.com/1.1/statuses/home_timeline.json", would just be "statuses/home_timeline.json".
 * @param params Can be nil. The Parameters that would go into the query. These typically are typed out like "some_page.json?query1=testing&querynumber2=test". We take care of formatting that for you, and encoding it in json. The Dictionary keys are used as the first part of the query, and the value is used after the "=". Formatted into a json encoded URL.
 * @param data Can be nil. The data encoded in the request body. We do no encoding, we simply put it as the request body.
 * @param user The user who is making the request to the network he is logged in to.
 * @param successHandler The callback for a successful query
 * @param errorHandler The callback for dealing with errors
 */
- (void)runSocialGraphQueryOnNetwork:(NSString *)network
                            withVerb:(NSString *)verb
                           baseQuery:(NSString *)base
                          parameters:(NSDictionary *)params
                             headers:(NSDictionary *)headers
                         messageData:(NSData *)data
                            withUser:(CMUser *)user
                       successHandler:(CMWebServicesSocialQuerySuccessCallback)successHandler
                        errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;

/**
 * Asynchronously execute a GET request with no Data. Convenience method.
 *
 * @param network The Network this request is targeting. @see CMSocialNetwork
 * @param base Can be nil, but probably shoudln't be most of the time. The base query for the request, before any "query" parameters. This does NOT include the hostname, or the version of the API. For example, "https://api.twitter.com/1.1/statuses/home_timeline.json", would just be "statuses/home_timeline.json".
 * @param params Can be nil. The Parameters that would go into the query. These typically are typed out like "some_page.json?query1=testing&querynumber2=test". We take care of formatting that for you, and encoding it in json. The Dictionary keys are used as the first part of the query, and the value is used after the "=". Formatted into a json encoded URL.
 * @param user The user who is making the request to the network he is logged in to.
 * @param successHandler The callback for a successful query
 * @param errorHandler The callback for dealing with errors
 */
- (void)runSocialGraphGETQueryOnNetwork:(NSString *)network
                           baseQuery:(NSString *)base
                          parameters:(NSDictionary *)params
                                headers:(NSDictionary *)headers
                            withUser:(CMUser *)user
                       successHandler:(CMWebServicesSocialQuerySuccessCallback)successHandler
                        errorHandler:(CMWebServiceFetchFailureCallback)errorHandler;


- (void)executeGenericRequest:(NSURLRequest *)request successHandler:(CMWebServiceGenericRequestCallback)successHandler errorHandler:(CMWebServiceErorCallack)errorHandler;

- (NSMutableURLRequest *)constructHTTPRequestWithVerb:(NSString *)verb URL:(NSURL *)url binaryData:(BOOL)isForBinaryData user:(CMUser *)user;

- (NSURL *)constructAppURLWithString:(NSString *)url andDescriptors:(NSArray *)descriptors;


@end
