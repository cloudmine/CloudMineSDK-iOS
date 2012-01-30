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

/** 
 * The user to be used when accessing user-level objects. This is ignored for app-level objects.
 *
 * <b>Note:</b> Changing this from one user to another will cause all the cached objects associated with the first
 * user to be removed. This won't have any affect on the objects if you have retained references to them elsewhere,
 * but it will have the effect of nullifying the <tt>store</tt> reference in all those objects. This is because since
 * you have changed the store's user ownership to User 2, the first set of objects (which belong to User 1) no longer
 * belong to the store. <b>This operation is thread-safe</b>.
 *
 * @see CMObject#store
 */
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
 * Convenience method to return a newly initialized CMStore instance.
 * Note that, like when using <tt>initWithUser:</tt>, you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 *
 * @param user The user to configure the store with.
 *
 * @see CMAPICredentials
 * @see CMUser
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
+ (CMStore *)storeWithUser:(CMUser *)theUser;

/**
 * Default constructor. Note that you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 * Using this method will not tie this store to any particular user, and all objects
 * you retrieve and upload will be app-level.
 *
 * @see CMAPICredentials
 */
- (id)init;

/**
 * Constructor that configures this store with a user.
 * Note that you must have already initialized the <tt>CMAPICredentials</tt> singleton
 * with your app identifier and secret key.
 *
 * @param user The user to configure the store with.
 *
 * @see CMAPICredentials
 * @see CMUser
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (id)initWithUser:(CMUser *)theUser;

/**
 * Downloads all app-level objects for your app's CloudMine object store.
 *
 * @param callback The callback to be triggered when all the objects are finished downloading.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/json_get
 */
- (void)allObjects:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options;

/**
 * Downloads all user-level objects for your app's CloudMine object store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param callback The callback to be triggered when all the objects are finished downloading.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/json_get
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)allUserObjects:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options;

/**
 * Downloads app-level objects for your app's CloudMine object store with the given keys.
 *
 * @param keys The keys of the objects you wish to download. Specifying a key for an object that does not exist will <b>not</b> cause an error.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/json_get
 */
- (void)objectsWithKeys:(NSArray *)keys callback:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options;

/**
 * Downloads user-level objects for your app's CloudMine object store with the given keys. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param keys The keys of the objects you wish to download. Specifying a key for an object that does not exist will <b>not</b> cause an error.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/json_get
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)userObjectsWithKeys:(NSArray *)keys callback:(CMStoreObjectFetchCallback)callback additionalOptions:(CMStoreOptions *)options;

/**
 * Downloads app-level objects of the given type from your app's CloudMine object store.
 *
 * @param klass The class of the objects you want to download. <tt>[klass className]</tt> is called to determine the remote type.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 *
 * @throws NSException An exception will be raised if <tt>klass</tt> doesn't respond to <tt>className</tt>.
 *
 * @see CMStoreOptions
 * @see CMSerializable#className
 * @see https://cloudmine.me/developer_zone#ref/json_get
 */
- (void)allObjects:(CMStoreObjectFetchCallback)callback ofType:(Class)klass additionalOptions:(CMStoreOptions *)options;

/**
 * Downloads user-level objects of the given type from your app's CloudMine object store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param klass The class of the objects you want to download. <tt>[klass className]</tt> is called to determine the remote type.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store OR if <tt>klass</tt> doesn't respond to <tt>className</tt>.
 *
 * @see CMStoreOptions
 * @see CMSerializable#className
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)allUserObjects:(CMStoreObjectFetchCallback)callback ofType:(Class)klass additionalOptions:(CMStoreOptions *)options;

/**
 * Performs a search across all app-level objects in your app's CloudMine object store.
 *
 * @param callback The callback to be triggered when all the objects are finished downloading.
 * @param query The search query to perform. This must conform to the syntax outlined in the CloudMine <a href="https://cloudmine.me/developer_zone#ref/query_syntax" target="_blank">documentation</a>.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/query_syntax
 */
- (void)searchObjects:(CMStoreObjectFetchCallback)callback query:(NSString *)query additionalOptions:(CMStoreOptions *)options;

/**
 * Performs a search across all user-level objects in your app's CloudMine object store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param callback The callback to be triggered when all the objects are finished downloading.
 * @param query The search query to perform. This must conform to the syntax outlined in the CloudMine <a href="https://cloudmine.me/developer_zone#ref/query_syntax" target="_blank">documentation</a>.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/query_syntax
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)searchUserObjects:(CMStoreObjectFetchCallback)callback query:(NSString *)query additionalOptions:(CMStoreOptions *)options;

/**
 * Downloads an app-level binary file from your app's CloudMine data store.
 *
 * @param callback The callback to be triggered when the file is finished downloading.
 * @param name The unique name of the file to download.
 *
 * @see https://cloudmine.me/developer_zone#ref/file_overview
 */
- (void)fileWithName:(NSString *)name callback:(CMStoreFileFetchCallback)callback;

/**
 * Downloads a user-level binary file from your app's CloudMine data store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param callback The callback to be triggered when the file is finished downloading.
 * @param name The unique name of the file to download.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/developer_zone#ref/file_overview
 */
- (void)userFileWithName:(NSString *)name callback:(CMStoreFileFetchCallback)callback;

/**
 * Synchronizes all the objects (user- and app-level) in the store with your app's CloudMine data store. User-level objects
 * will only be sync'd if there is a user associated with this store.
 * This will cause all objects deleted from this store to be deleted remotely as well. Objects updated server-side will
 * be downloaded and merged locally.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)syncAll:(CMStoreUploadCallback)callback;

/**
 * Saves all the app-level objects in the store to your app's CloudMine data store.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)syncAllAppObjects:(CMStoreUploadCallback)callback;

/**
 * Saves all the user-objects in the store to your app's CloudMine data store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_update
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)syncAllUserObjects:(CMStoreUploadCallback)callback;

/**
 * Saves an individual object to your app's CloudMine data store at the app-level. If this object doesn't
 * already belong to this store, it will automatically be added as well. This has the additional effect of increasing
 * the object's retain count by 1 as well as setting its <tt>store</tt> property to this store.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see CMObject#store
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)saveObject:(CMObject *)theObject callback:(CMStoreUploadCallback)callback;

/**
 * Saves an individual object to your app's CloudMine data store at the user-level. The store must be configured 
 * with a user or else calling this method will throw an exception. If this object doesn't
 * already belong to this store, it will automatically be added as well. This has the additional effect of increasing
 * the object's retain count by 1 as well as setting its <tt>store</tt> property to this store.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMObject#store
 * @see https://cloudmine.me/developer_zone#ref/json_update
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)saveUserObject:(CMObject *)theObject callback:(CMStoreUploadCallback)callback;

/**
 * Adds an app-level object to this store. Doing this also sets the object's <tt>store</tt> property to this store.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param theObject The object to add.
 *
 * @see CMObject#store
 */
- (void)addObject:(CMObject *)theObject;

/**
 * Adds a user-level object to this store. Doing this also sets the object's <tt>store</tt> property to this store.
 * No persistence is performed as a result of calling this method. The store must be configured 
 * with a user or else calling this method will throw an exception. <b>This method is thread-safe</b>.
 *
 * @param theObject The object to add.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMObject#store
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)addUserObject:(CMObject *)theObject;

/**
 * Removes an app-level object to this store. Doing this also nullifies the object's <tt>store</tt> property.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param theObject The object to remove.
 *
 * @see CMObject#store
 */
- (void)removeObject:(CMObject *)theObject;
- (void)removeUserObject:(CMObject *)theObject;

@end
