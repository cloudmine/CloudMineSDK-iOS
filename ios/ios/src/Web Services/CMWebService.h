//
//  CMWebService.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import <Foundation/Foundation.h>

@class ASINetworkQueue;
@class CMUser;
@class CMServerFunction;

/**
 * Base URL for the current version of the CloudMine API.
 */
#define CM_BASE_URL @"https://api.cloudmine.me/v1"

/**
 * @enum Enumeration of possible results from a file upload operation.
 */
typedef enum {
    /** File was created new on the server */
    CMFileCreated = 0,
    
    /** File previously existed on server and was replaced with new content */
    CMFileUpdated
} CMFileUploadResult;

/**
 * Base class for all classes concerned with the communication between the client device and the CloudMine 
 * web services.
 */
@interface CMWebService : NSObject {
    NSString *_apiKey;
    NSString *_appKey;
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
- (id)initWithAPIKey:(NSString *)apiKey appKey:(NSString *)appKey;

/**
 * Asynchronously retrieve objects for the named user-level keys. On completion, the <tt>successHandler</tt> block 
 * will be called with a dictionary of the objects retrieved as well as a dictionary of the key-related errors returned from the server.
 *
 * @param keys The keys to fetch.
 * @param function The server-side code snippet and related options to execute with this request, or nil if none.
 * @param credentials The user whose data to fetch. If nil, fetches app-level objects.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)getValuesForKeys:(NSArray *)keys  
      serverSideFunction:(CMServerFunction *)function
     withUserCredentials:(CMUser *)credentials
          successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
            errorHandler:(void (^)(NSError *error))errorHandler;

- (void)searchValuesFor:(NSString *)searchQuery
     serverSideFunction:(CMServerFunction *)function
    withUserCredentials:(CMUser *)credentials
         successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
           errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously retrieve a binary file for the named user-leve key. On completion, the <tt>successHandler</tt> block 
 * will be called with the raw data from the server.
 *
 * @param keys The key of the binary file to fetch.
 * @param credentials The user whose data to fetch. If nil, fetches app-level objects.
 * @param successHandler The block to be called when the file has been fully downloaded.
 * @param errorHandler The block to be called if the request failed.
 */
- (void)getBinaryDataNamed:(NSString *)key
       withUserCredentials:(CMUser *)credentials
            successHandler:(void (^)(NSData *data))successHandler 
              errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously update one or more objects for the user-level keys included in <tt>data</tt>. On completion, the <tt>successHandler</tt>  
 * block will be called with a dictionary of the keys of the objects that were created and updated as well as a dictionary of the
 * key-related errors returned from the server.
 *
 * @param data A dictionary mapping top-level keys to the values to be used to update the object.
 * @param function The server-side code snippet and related options to execute with this request, or nil if none.
 * @param credentials The user whose data to write. If nil, writes as app-level objects.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)updateValuesFromDictionary:(NSDictionary *)data 
                serverSideFunction:(CMServerFunction *)function
               withUserCredentials:(CMUser *)credentials 
                    successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
                      errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously upload the raw binary data contained in <tt>data</tt> with an optional MIME type as a user-level object.
 * On completion, the <tt>successHandler</tt> block will be called with a status code indicating 
 * whether a file with the given key previously existed on the server or had to be created new.
 *
 * @param data The raw binary data of the file to upload.
 * @param key The unique name of this file.
 * @param mimeType The MIME type of this file. When later fetched, this MIME type will be used in the Content-Type header. If <tt>nil</tt>, defaults to <tt>application/octet-stream</tt>.
 * @param credentials The user whose data to write. If nil, writes as app-level objects.
 * @param successHandler The block to be called when the file has finished uploading. The <tt>result</tt> parameter indicates whether the file was new to the server or not.
 * @param errorHandler The block to be called if the request failed.
 */
- (void)uploadBinaryData:(NSData *)data
                   named:(NSString *)key
              ofMimeType:(NSString *)mimeType
     withUserCredentials:(CMUser *)credentials
          successHandler:(void (^)(CMFileUploadResult result))successHandler 
            errorHandler:(void (^)(NSError *error))errorHandler;

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
 * @param credentials The user whose data to write. If nil, writes as app-level objects.
 * @param successHandler The block to be called when the file has finished uploading. The <tt>result</tt> parameter indicates whether the file was new to the server or not.
 * @param errorHandler The block to be called if the request failed.
 */
- (void)uploadFileAtPath:(NSString *)path
                   named:(NSString *)key
              ofMimeType:(NSString *)mimeType
     withUserCredentials:(CMUser *)credentials
          successHandler:(void (^)(CMFileUploadResult result))successHandler 
            errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously create or replace one or more objects for the values of the user-level keys included in <tt>data</tt>. On completion, the <tt>successHandler</tt>  
 * block will be called with a dictionary of the keys of the objects that were created and replaced as well as a dictionary of the
 * key-related errors returned from the server.
 *
 * Note that if the key already exists server-side, this method will fully replace its value. For updating via merge, see the <tt>updateValuesFromDictionary</tt> methods.
 *
 * @see updateValuesFromDictionary:userCredentials:successHandler:errorHandler:
 *
 * @param data A dictionary mapping top-level keys to the values to be used to update the object.
 * @param function The server-side code snippet and related options to execute with this request, or nil if none.
 * @param credentials The user whose data to write. If nil, writes as app-level objects.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)setValuesFromDictionary:(NSDictionary *)data  
             serverSideFunction:(CMServerFunction *)function
            withUserCredentials:(CMUser *)credentials 
                 successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
                   errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously delete objects for the named user-level keys. On completion, the <tt>successHandler</tt> block 
 * will be called.
 *
 * For the sake of consistency, <tt>results</tt> and <tt>errors</tt> will be sent to the callback like with all the other methods in this class,
 * however they will <strong>always</strong> be empty.
 *
 * @param keys The keys to delete. If <tt>nil</tt> or an empty array, <strong>all of this user's objects will be deleted.</strong>
 * @param credentials The user whose data to delete. If nil, deletes app-level objects.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)deleteValuesForKeys:(NSArray *)keys 
        withUserCredentials:(CMUser *)credentials 
             successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
               errorHandler:(void (^)(NSError *error))errorHandler;

@end
