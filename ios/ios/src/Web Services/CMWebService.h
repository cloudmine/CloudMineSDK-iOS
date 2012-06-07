//
//  CMWebService.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import <YAJLiOS/YAJL.h>
#import "CMFileUploadResult.h"
#import "CMUserAccountResult.h"

@class ASINetworkQueue;
@class CMUser;
@class CMServerFunction;
@class CMPagingDescriptor;
@class CMSortDescriptor;

/**
 * Base URL for the current version of the CloudMine API.
 */
#ifdef DEBUG
#define CM_BASE_URL @"http://localhost:3001/v1"
#else
#define CM_BASE_URL @"https://api.cloudmine.me/v1"
#endif

/**
 * Callback block signature for all operations on <tt>CMWebService</tt> that fetch objects
 * from the CloudMine servers. These blocks return <tt>void</tt> and take a dictionary of results,
 * a dictionary of errors, a dictionary of metadata, and a dynamic snippet result as arguments. 
 * These map directly with the CloudMine API response format.
 */
typedef void (^CMWebServiceObjectFetchSuccessCallback)(NSDictionary *results, NSDictionary *errors, NSDictionary *meta, id snippetResult, NSNumber *count);

/**
 * Callback block signature for <b>all</b> operations on <tt>CMStore</tt> that can fail. These are general
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
typedef void (^CMWebServiceFileUploadSuccessCallback)(CMFileUploadResult result, NSString *fileKey, id snippetResult);

/**
 * Callback block signature for all operations on <tt>CMWebService</tt> that download binary files from
 * the CloudMine servers. These blocks return <tt>void</tt> and take an <tt>NSData</tt> instance that contains
 * the raw data for the file as well as a string with the content type of the file returned from the server.
 */
typedef void (^CMWebServiceFileFetchSuccessCallback)(NSData *data, NSString *contentType);

/**
 * Callback block signature for all operations on <tt>CMWebService</tt> and <tt>CMUser</tt> that involve the management
 * of user accounts and user sessions. These blocks return <tt>void</tt> and take a <tt>CMUserAccountResult</tt> code
 * that represents the result of the operation as well as an <tt>NSDictionary</tt> containing the dictionary representation
 * of the response body from the server.
 */
typedef void (^CMWebServiceUserAccountOperationCallback)(CMUserAccountResult result, NSDictionary *responseBody);

/**
 * Base class for all classes concerned with the communication between the client device and the CloudMine
 * web services.
 */
@interface CMWebService : NSObject {
    NSString *_appSecret;
    NSString *_appIdentifier;
}

/**
 * The message queue used to send messages to the CloudMine web services.
 *
 * One of these exists for each instance of <tt>CMWebService</tt>, allowing you to parallelize
 * network communication.
 */
@property (nonatomic, strong) ASINetworkQueue *networkQueue;

/**
 * Default initializer for the web service connector. You <strong>must</strong> have already configured the
 * <tt>CMUserCredentials</tt> singleton or an exception will be thrown.
 *
 * @throws NSInternalInconsistencyException <tt>CMUserCredentials</tt> has not been configured.
 */
- (id)init;

/**
 * Initializes an instance of a web service connector with the given API key and secret app key.
 */
- (id)initWithAppSecret:(NSString *)appSecret appIdentifier:(NSString *)appIdentifier;

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
 * @see https://cloudmine.me/developer_zone#ref/account_login
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
 * @see https://cloudmine.me/developer_zone#ref/account_logout
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
 * @see https://cloudmine.me/developer_zone#ref/account_create
 */
- (void)createAccountWithUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback;

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
 * @see https://cloudmine.me/developer_zone#ref/password_change
 */
- (void)changePasswordForUser:(CMUser *)user oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword callback:(CMWebServiceUserAccountOperationCallback)callback;

/**
 * Asynchronously reset the password for the given user. This method is used to reset a user's password if
 * he or she forgot it. This method of course does not require the user to be logged in in order to function.
 * On completion, the <tt>callback</tt> block will be called with the result  of the operation and the body of the
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
 * @see https://cloudmine.me/developer_zone#ref/password_reset
 */
- (void)resetForgottenPasswordForUser:(CMUser *)user callback:(CMWebServiceUserAccountOperationCallback)callback;

@end
