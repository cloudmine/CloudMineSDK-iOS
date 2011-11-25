//
//  CMWebService.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue;
@class CMUserCredentials;
@class CMServerFunction;

/**
 * Base URL for the current version of the CloudMine API.
 */
#define CM_BASE_URL @"https://api.cloudmine.me/v1"

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
 * @throws NSInternalConsistencyException <tt>CMUserCredentials</tt> has not been configured.
 */
- (id)init;

/**
 * Initializes an instance of a web service connector with the given API key and secret app key.
 */
- (id)initWithAPIKey:(NSString *)apiKey appKey:(NSString *)appKey;

/**
 * Asynchronously retrieve objects for the named app-level keys. On completion, the <tt>successHandler</tt> block 
 * will be called with a dictionary of the objects retrieved as well as a dictionary of the key-related errors returned from the server.
 *
 * @param keys The keys to fetch. If <tt>nil</tt> or an empty array, all objects will be returned.
 * @param serverSideFunction The server-side code snippet and related options to execute with this request, or nil if none.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)getValuesForKeys:(NSArray *)keys 
      serverSideFunction:(CMServerFunction *)function
          successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler
            errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously retrieve objects for the named user-level keys. On completion, the <tt>successHandler</tt> block 
 * will be called with a dictionary of the objects retrieved as well as a dictionary of the key-related errors returned from the server.
 *
 * @param keys The keys to fetch.
 * @param serverSideFunction The server-side code snippet and related options to execute with this request, or nil if none.
 * @param credentials The user identifier and password of the user.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)getValuesForKeys:(NSArray *)keys  
      serverSideFunction:(CMServerFunction *)function
     withUserCredentials:(CMUserCredentials *)credentials
          successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
            errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously update one or more objects for the app-level keys included in <tt>data</tt>. On completion, the <tt>successHandler</tt>  
 * block will be called with a dictionary of the keys of the objects that were created and updated as well as a dictionary of the
 * key-related errors returned from the server.
 *
 * @param data A dictionary mapping top-level keys to the values to be used to update the object.
 * @param serverSideFunction The server-side code snippet and related options to execute with this request, or nil if none.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)updateValuesFromDictionary:(NSDictionary *)data  
                serverSideFunction:(CMServerFunction *)function
                    successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
                      errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously update one or more objects for the user-level keys included in <tt>data</tt>. On completion, the <tt>successHandler</tt>  
 * block will be called with a dictionary of the keys of the objects that were created and updated as well as a dictionary of the
 * key-related errors returned from the server.
 *
 * @param data A dictionary mapping top-level keys to the values to be used to update the object.
 * @param serverSideFunction The server-side code snippet and related options to execute with this request, or nil if none.
 * @param credentials The user identifier and password of the user.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)updateValuesFromDictionary:(NSDictionary *)data 
                serverSideFunction:(CMServerFunction *)function
               withUserCredentials:(CMUserCredentials *)credentials 
                    successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
                      errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously create or replace one or more objects for the values of the app-level keys included in <tt>data</tt>. On completion, the <tt>successHandler</tt>  
 * block will be called with a dictionary of the keys of the objects that were created and replaced as well as a dictionary of the
 * key-related errors returned from the server.
 *
 * Note that if the key already exists server-side, this method will fully replace its value. For updating via merge, see the <tt>updateValuesFromDictionary</tt> methods.
 *
 * @see updateValuesFromDictionary:successHandler:errorHandler:
 *
 * @param data A dictionary mapping top-level keys to the values to be used to update the object.
 * @param serverSideFunction The server-side code snippet and related options to execute with this request, or nil if none.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)setValuesFromDictionary:(NSDictionary *)data  
             serverSideFunction:(CMServerFunction *)function
                 successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
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
 * @param serverSideFunction The server-side code snippet and related options to execute with this request, or nil if none.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)setValuesFromDictionary:(NSDictionary *)data  
             serverSideFunction:(CMServerFunction *)function
            withUserCredentials:(CMUserCredentials *)credentials 
                 successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
                   errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously delete objects for the named app-level keys. On completion, the <tt>successHandler</tt> block 
 * will be called.
 *
 * For the sake of consistency, <tt>results</tt> and <tt>errors</tt> will be sent to the callback like with all the other methods in this class,
 * however they will <strong>always</strong> be empty.
 *
 * @param keys The keys to delete. If <tt>nil</tt> or an empty array, <strong>all objects will be deleted.</strong>
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)deleteValuesForKeys:(NSArray *)keys 
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
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)deleteValuesForKeys:(NSArray *)keys 
        withUserCredentials:(CMUserCredentials *)credentials 
             successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
               errorHandler:(void (^)(NSError *error))errorHandler;

@end
