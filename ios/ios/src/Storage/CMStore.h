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
#import "CMFileUploadResult.h"

@class CMObject;

/**
 * Name of the notification that is sent out when an object is deleted.
 */
extern NSString * const CMStoreObjectDeletedNotification;

/** Defines possible ownership levels of a CMObject. */
typedef enum {
    /** The ownership level could not be determined. This is usually because the object doesn't belong to a store. */
    CMObjectOwnershipUndefinedLevel = -1,
    
    /** The object is app-level and is owned by no particular user. */
    CMObjectOwnershipAppLevel = 0,
    
    /** 
     * The object is owned by a particular user, specifically the user of the store where the object is held.
     * @see CMStore#user
     */
    CMObjectOwnershipUserLevel
} CMObjectOwnershipLevel;

/**
 * This is the high-level interface for interacting with remote objects stored on CloudMine.
 * Note that all the methods here that involve network operations are asynchronous to avoid blocking
 * your app's UI thread. Synchronous versions will come eventually for cases where you are managing a 
 * number of threads and can guarantee that blocking network operations will execute on a background thread.
 *
 * All of the async methods in this class take a callback of type <tt>CMStoreObjectCallback</tt> that will
 * be called with all the object instances once they are finished downloading and inflating.
 *
 * You can subscribe to CMStores using <tt>NSNotificationCenter</tt> and listening for
 * <tt>CMStoreObjectDeletedNotification</tt>. It will be triggered when any object managed by the store
 * is deleted. The <tt>userInfo</tt> dictionary in the <tt>NSNotification</tt> object passed to your handler
 * will contain a mapping of object IDs to the object instances that were deleted.
 */
@interface CMStore : NSObject {
@private
    NSMutableDictionary *_cachedAppObjects;
    NSMutableDictionary *_cachedUserObjects;
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
 * @param theUser The user to configure the store with.
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
 * @param theUser The user to configure the store with.
 *
 * @see CMAPICredentials
 * @see CMUser
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (id)initWithUser:(CMUser *)theUser;

/**
 * Downloads all app-level objects for your app's CloudMine object store.
 *
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/json_get
 */
- (void)allObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Downloads all user-level objects for your app's CloudMine object store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/json_get
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)allUserObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Downloads app-level objects for your app's CloudMine object store with the given keys.
 *
 * @param keys The keys of the objects you wish to download. Specifying a key for an object that does not exist will <b>not</b> cause an error.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/json_get
 */
- (void)objectsWithKeys:(NSArray *)keys additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Downloads user-level objects for your app's CloudMine object store with the given keys. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param keys The keys of the objects you wish to download. Specifying a key for an object that does not exist will <b>not</b> cause an error.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/json_get
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)userObjectsWithKeys:(NSArray *)keys additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Downloads app-level objects of the given type from your app's CloudMine object store.
 *
 * @param klass The class of the objects you want to download. <tt>[klass className]</tt> is called to determine the remote type.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>
 * @param callback The callback to be triggered when all the objects are finished downloading.>.
 *
 * @throws NSException An exception will be raised if <tt>klass</tt> doesn't respond to <tt>className</tt>.
 *
 * @see CMStoreOptions
 * @see CMSerializable#className
 * @see https://cloudmine.me/developer_zone#ref/json_get
 */
- (void)allObjectsOfType:(Class)klass additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Downloads user-level objects of the given type from your app's CloudMine object store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param klass The class of the objects you want to download. <tt>[klass className]</tt> is called to determine the remote type.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store OR if <tt>klass</tt> doesn't respond to <tt>className</tt>.
 *
 * @see CMStoreOptions
 * @see CMSerializable#className
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)allUserObjectsOfType:(Class)klass additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Performs a search across all app-level objects in your app's CloudMine object store.
 *
 * @param query The search query to perform. This must conform to the syntax outlined in the CloudMine <a href="https://cloudmine.me/developer_zone#ref/query_syntax" target="_blank">documentation</a>.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/query_syntax
 */
- (void)searchObjects:(NSString *)query additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Performs a search across all user-level objects in your app's CloudMine object store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param query The search query to perform. This must conform to the syntax outlined in the CloudMine <a href="https://cloudmine.me/developer_zone#ref/query_syntax" target="_blank">documentation</a>.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/developer_zone#ref/query_syntax
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)searchUserObjects:(NSString *)query additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

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
 * Saves all the objects (user- and app-level) in the store with your app's CloudMine data store. User-level objects
 * will only be sync'd if there is a user associated with this store.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)saveAll:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the objects (user- and app-level) in the store with your app's CloudMine data store. User-level objects
 * will only be sync'd if there is a user associated with this store.
 *
 * @param options Use these options to specify a server-side function to call after persisting the objects. Only CMStoreOptions#serverSideFunction is used.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)saveAllWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the app-level objects in the store to your app's CloudMine data store.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)saveAllAppObjects:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the app-level objects in the store to your app's CloudMine data store.
 *
 * @param options Use these options to specify a server-side function to call after persisting the objects. Only CMStoreOptions#serverSideFunction is used.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)saveAllAppObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

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
- (void)saveAllUserObjects:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the user-objects in the store to your app's CloudMine data store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param options Use these options to specify a server-side function to call after persisting the objects. Only CMStoreOptions#serverSideFunction is used.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_update
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)saveAllUserObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves an individual object to your app's CloudMine data store at the app-level. If this object doesn't
 * already belong to this store, it will automatically be added as well. This has the additional effect of increasing
 * the object's retain count by 1 as well as setting its <tt>store</tt> property to this store.
 *
 * @param theObject The object to save.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see CMObject#store
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)saveObject:(CMObject *)theObject callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves an individual object to your app's CloudMine data store at the app-level. If this object doesn't
 * already belong to this store, it will automatically be added as well. This has the additional effect of increasing
 * the object's retain count by 1 as well as setting its <tt>store</tt> property to this store.
 *
 * @param theObject The object to save.
 * @param options Use these options to specify a server-side function to call after persisting the objects. Only CMStoreOptions#serverSideFunction is used.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see CMObject#store
 * @see https://cloudmine.me/developer_zone#ref/json_update
 */
- (void)saveObject:(CMObject *)theObject additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves an individual object to your app's CloudMine data store at the user-level. The store must be configured 
 * with a user or else calling this method will throw an exception. If this object doesn't
 * already belong to this store, it will automatically be added as well. This has the additional effect of increasing
 * the object's retain count by 1 as well as setting its <tt>store</tt> property to this store.
 *
 * @param theObject The object to save.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMObject#store
 * @see https://cloudmine.me/developer_zone#ref/json_update
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)saveUserObject:(CMObject *)theObject callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves an individual object to your app's CloudMine data store at the user-level. The store must be configured 
 * with a user or else calling this method will throw an exception. If this object doesn't
 * already belong to this store, it will automatically be added as well. This has the additional effect of increasing
 * the object's retain count by 1 as well as setting its <tt>store</tt> property to this store.
 *
 * @param theObject The object to save.
 * @param options Use these options to specify a server-side function to call after persisting the objects. Only CMStoreOptions#serverSideFunction is used.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMObject#store
 * @see https://cloudmine.me/developer_zone#ref/json_update
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)saveUserObject:(CMObject *)theObject additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

/**
 * Deletes the given app-level object from your app's CloudMine data store and removes the object from this store.
 * This also triggers a notification of type <tt>CMStoreObjectDeletedNotification</tt> to subscribers of the store
 * so you can do any other necessary cleanup throughout your app. This notification is triggered <b>before</b> the object
 * is deleted from the server.
 *
 * @param theObject The object to delete and remove from the store.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_delete
 */
- (void)deleteObject:(id<CMSerializable>)theObject callback:(CMStoreDeleteCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the app-level. This works by streaming the contents of the
 * file directly from the filesystem, thus never loading the file into memory. You must give the file a name that is
 * unique within your app's data store.
 *
 * @param url The absolute URL to the location of the file on the device.
 * @param name The name to give the file on CloudMine. <b>This must be unique throughout all instances of your app.</b>
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see https://cloudmine.me/developer_zone#ref/file_set
 */
- (void)saveFileAtURL:(NSURL *)url named:(NSString *)name callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the user-level. The store must be configured 
 * with a user or else calling this method will throw an exception. This works by streaming the contents of the
 * file directly from the filesystem, thus never loading the file into memory. You must give the file a name that is
 * unique within your app's data store.
 *
 * @param url The absolute URL to the location of the file on the device.
 * @param name The name to give the file on CloudMine. <b>This must be unique throughout all instances of your app.</b>
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/developer_zone#ref/file_set
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)saveUserFileAtURL:(NSURL *)url named:(NSString *)name callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the app-level. This uses the raw data of the file's contents
 * contained in an <tt>NSData</tt> object. You must give the file a name that is unique within your app's data store.
 *
 * @param data The raw contents of the file.
 * @param name The name to give the file on CloudMine. <b>This must be unique throughout all instances of your app.</b>
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see https://cloudmine.me/developer_zone#ref/file_set
 */
- (void)saveFileWithData:(NSData *)data named:(NSString *)name callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the user-level. The store must be configured 
 * with a user or else calling this method will throw an exception. This uses the raw data of the file's contents
 * contained in an <tt>NSData</tt> object. You must give the file a name that is unique within your app's data store.
 *
 * @param data The raw contents of the file.
 * @param name The name to give the file on CloudMine. <b>This must be unique throughout all instances of your app.</b>
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/developer_zone#ref/file_set
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)saveUserFileWithData:(NSData *)data named:(NSString *)name callback:(CMStoreFileUploadCallback)callback;

/**
 * Deletes the given app-level file from your app's CloudMine data store.
 *
 * @param name The name of the file to delete.
 * @param callback The callback to be triggered when the file has been deleted.
 *
 * @see https://cloudmine.me/developer_zone#ref/file_delete
 */
- (void)deleteFileNamed:(NSString *)name callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes the given user-level file from your app's CloudMine data store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 *
 * @param name The name of the file to delete.
 * @param callback The callback to be triggered when the file has been deleted.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/developer_zone#ref/file_delete
 */
- (void)deleteUserFileNamed:(NSString *)name callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes the given user-level object from your app's CloudMine data store and removes the object from this store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 * This also triggers a notification of type <tt>CMStoreObjectDeletedNotification</tt> to subscribers of the store
 * so you can do any other necessary cleanup throughout your app. This notification is triggered <b>before</b> the object
 * is deleted from the server.
 *
 * @param theObject The object to delete and remove from the store.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_delete
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)deleteUserObject:(id<CMSerializable>)theObject callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes all the given app-level objects from your app's CloudMine data store and removes the object from this store.
 * This also triggers a notification of type <tt>CMStoreObjectDeletedNotification</tt> to subscribers of the store
 * so you can do any other necessary cleanup throughout your app. This notification is triggered <b>before</b> the objects
 * are deleted from the server.
 *
 * @param objects The objects to delete and remove from the store.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_delete
 */
- (void)deleteObjects:(NSArray *)objects callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes all the given user-level objects from your app's CloudMine data store and removes the object from this store. The store must be configured 
 * with a user or else calling this method will throw an exception.
 * This also triggers a notification of type <tt>CMStoreObjectDeletedNotification</tt> to subscribers of the store
 * so you can do any other necessary cleanup throughout your app. This notification is triggered <b>before</b> the objects
 * are deleted from the server.
 *
 * @param objects The objects to delete and remove from the store.
 *
 * @see https://cloudmine.me/developer_zone#ref/json_delete
 * @see https://cloudmine.me/developer_zone#ref/account_overview
 */
- (void)deleteUserObjects:(NSArray *)objects callback:(CMStoreDeleteCallback)callback;

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

/**
 * Removes a user-level object to this store. The store must be configured with a user or else calling this method will throw an exception.
 * Doing this also nullifies the object's <tt>store</tt> property.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param theObject The object to remove.
 *
 * @see CMObject#store
 */
- (void)removeUserObject:(CMObject *)theObject;

/**
 * @param theObject
 * @return The ownership level of the object given.
 * @see CMObjectOwnershipLevel
 */
- (CMObjectOwnershipLevel)objectOwnershipLevel:(CMObject *)theObject;

@end
