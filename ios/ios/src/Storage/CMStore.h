//
//  CMStore.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import "CMWebService.h"
#import "CMStoreOptions.h"
#import "CMServerFunction.h"
#import "CMPagingDescriptor.h"
#import "CMUser.h"
#import "CMFile.h"
#import "CMStoreCallbacks.h"

@class CMObject;

/**
 * This is the high-level interface for interacting with remote objects stored on CloudMine.
 * Note that all the methods here that involve network operations are asynchronous to avoid blocking
 * your app's UI thread. Synchronous versions will come eventually for cases where you are managing a 
 * number of threads and can guarantee that blocking network operations will execute on a background thread.
 *
 * All of the async methods in this class take a callback of type <tt>CMStoreObjectCallback</tt> that will
 * be called with all the object instances once they are finished downloading and inflating.
 */
@interface CMStore : NSObject {
@private
    NSMutableSet *_cachedAppObjects;
    NSMutableSet *_cachedUserObjects;
}

/** The <tt>CMWebService</tt> instance that backs this store */
@property (nonatomic, strong) CMWebService *webService;

/** The user to be used when accessing user-level objects. This is ignored for app-level objects. */
@property (nonatomic, strong) CMUser *user;

/** The last error that occured during a store-based operation. */
@property (readonly, strong) NSError *lastError;

/**
 * Convenience method to return a newly initialized CMStore instance.
 * Note that, like when using <tt>init</tt>, you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 *
 * @see CMAPICredentials
 */
+ (CMStore *)store;

/**
 * Default constructor. Note that you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 *
 * @see CMAPICredentials
 */
- (id)init;

- (id)initWithUser:(CMUser *)theUser;

- (void)allObjects:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options;
- (void)allUserObjects:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options;

- (void)objectsWithKeys:(NSArray *)keys callback:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options;
- (void)userObjectsWithKeys:(NSArray *)keys callback:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options;

- (void)allObjects:(CMStoreObjectFetchCallback)callback ofType:(NSString *)type additionalOptions:(CMStoreOptions *)options;
- (void)allUserObjects:(CMStoreObjectFetchCallback)callback ofType:(NSString *)type additionalOptions:(CMStoreOptions *)options;

- (void)searchObjects:(CMStoreObjectFetchCallback)callback query:(NSString *)query additionalOptions:(CMStoreOptions *)options;
- (void)searchUserObjects:(CMStoreObjectFetchCallback)callback query:(NSString *)query additionalOptions:(CMStoreOptions *)options;

- (void)fileWithName:(NSString *)name callback:(CMStoreFileCallback)callback;
- (void)userFileWithName:(NSString *)name callback:(CMStoreFileCallback)callback;

- (void)saveObject:(CMObject *)theObject callback:(CMStoreObjectUploadCallback)callback;

- (void)addObject:(CMObject *)theObject;
- (void)addObjectBelongingToUser:(CMObject *)theObject;
- (void)removeObject:(CMObject *)theObject;
- (void)removeObjectBelongingToUser:(CMObject *)theObject;

@end
