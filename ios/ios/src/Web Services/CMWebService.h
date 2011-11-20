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
 * @param keys The keys to fetch.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)getValuesForKeys:(NSArray *)keys successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
            errorHandler:(void (^)(NSError *error))errorHandler;

/**
 * Asynchronously retrieve objects for the named user-level keys. On completion, the <tt>successHandler</tt> block 
 * will be called with a dictionary of the objects retrieved as well as a dictionary of the key-related errors returned from the server.
 *
 * @param keys The keys to fetch.
 * @param credentials The user identifier and password of the user.
 * @param successHandler The block to be called when the objects have been populated.
 * @param errorHandler The block to be called if the entire request failed (i.e. if there is no network connectivity).
 */
- (void)getValuesForKeys:(NSArray *)keys withUserCredentials:(CMUserCredentials *)credentials
          successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler errorHandler:(void (^)(NSError *error))errorHandler;

- (void)updateValuesForKeys:(NSArray *)keys successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
               errorHandler:(void (^)(NSError *error))errorHandler;

- (void)updateValuesForKeys:(NSArray *)keys withUserCredentials:(CMUserCredentials *)credentials 
             successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler errorHandler:(void (^)(NSError *error))errorHandler;

- (void)setValuesForKeys:(NSArray *)keys successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
            errorHandler:(void (^)(NSError *error))errorHandler;

- (void)setValuesForKeys:(NSArray *)keys withUserCredentials:(CMUserCredentials *)credentials 
          successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler errorHandler:(void (^)(NSError *error))errorHandler;

- (void)deleteAllWithSuccessHandler:(void (^)(void)) errorHandler:(void (^)(NSError *error))errorHandler;

- (void)deleteValuesForKeys:(NSArray *)keys successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler 
               errorHandler:(void (^)(NSError *error))errorHandler;

- (void)deleteValuesForKeys:(NSArray *)keys withUserCredentials:(CMUserCredentials *)credentials 
             successHandler:(void (^)(NSDictionary *results, NSDictionary *errors))successHandler errorHandler:(void (^)(NSError *error))errorHandle;

@end
