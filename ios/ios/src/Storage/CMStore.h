//
//  CMStore.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import "CMStoreOptions.h"
#import "CMServerFunction.h"
#import "CMPagingDescriptor.h"
#import "CMUser.h"
#import "CMFile.h"
#import "CMStoreCallbacks.h"
#import "CMFileUploadResult.h"
#import "CMObjectOwnershipLevel.h"

#import "CMObjectFetchResponse.h"
#import "CMObjectUploadResponse.h"
#import "CMFileFetchResponse.h"
#import "CMFileUploadResult.h"
#import "CMDeleteResponse.h"
#import "CMDeviceTokenResult.h"

@class CMWebService;
@class CMObject;
@class CMACL;

extern NSString * const CMErrorDomain;

typedef enum {
    CMErrorUnknown,
    CMErrorServerConnectionFailed,
    CMErrorServerError,
    CMErrorNotFound,
    CMErrorInvalidRequest,
    CMErrorInvalidResponse,
    CMErrorUnauthorized
} CMErrorCode;

/**
 * Name of the notification that is sent out when an object is deleted.
 */
extern NSString * const CMStoreObjectDeletedNotification;

/**
 * This is the high-level interface for interacting with remote objects stored on CloudMine.
 * Note that all the methods here that involve network operations are asynchronous to avoid blocking
 * your app's UI thread. Synchronous versions will come eventually for cases where you are managing a
 * number of threads and can guarantee that blocking network operations will execute on a background thread.
 *
 * Most apps will only need one store to store and retrieve remote objects. You can use <tt>CMStore#defaultStore</tt>
 * to access this store. It is fully managed for you by the CloudMine SDK.
 *
 * All of the async methods in this class take a callback of type <tt>CMStoreObjectCallback</tt> that will
 * be called with all the object instances once they are finished downloading and inflating.
 *
 * You can subscribe to CMStores using <tt>NSNotificationCenter</tt> and listening for
 * <tt>CMStoreObjectDeletedNotification</tt>. It will be triggered when any object managed by the store
 * is deleted. The <tt>userInfo</tt> dictionary in the <tt>NSNotification</tt> object passed to your handler
 * will contain a mapping of object IDs to the object instances that were deleted.
 */
@interface CMStore : NSObject

/** The <tt>CMWebService</tt> instance that backs this store */
@property (nonatomic, strong) CMWebService *webService;

/**
 * The user to be used when accessing user-level objects. This is ignored for app-level objects.
 *
 * @discussion
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
 * The default store for this app.
 *
 * @discussion
 * <b>Most apps need only a single store.</b> Use this method to access a shared store
 * that you can safely use across your app for storing and retrieving all your model objects.
 * If for some reason you need more than one store in your app, you can use <tt>CMStore</tt>'s
 * constructors as usual.
 *
 * You must have already initialized the <tt>CMAPICredentials</tt> singleton
 * with your app identifier and secret key.
 *
 * @return CMStore
 *
 * @see CMAPICredentials
 */
+ (CMStore *)defaultStore;

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
 * Note that, like when using <tt>init</tt>, you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 *
 * @see CMAPICredentials
 */
+ (CMStore *)storeWithBaseURL:(NSString *)url;

/**
 * Convenience method to return a newly initialized CMStore instance.
 * Note that, like when using <tt>initWithUser:</tt>, you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 *
 * @param theUser The user to configure the store with.
 *
 * @see CMAPICredentials
 * @see CMUser
 */
+ (CMStore *)storeWithUser:(CMUser *)theUser;

/**
 * Convenience method to return a newly initialized CMStore instance.
 * Note that, like when using <tt>initWithUser:</tt>, you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 *
 * @param theUser The user to configure the store with.
 * @param baseURL The base URL you want this instance to point to.
 *
 * @see CMAPICredentials
 * @see CMUser
 */
+ (CMStore *)storeWithUser:(CMUser *)theUser baseURL:(NSString *)url;

/**
 * Note that you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 * Using this method will not tie this store to any particular user, and all objects
 * you retrieve and upload will be app-level. This will default to the CloudMine base URL
 * by default.
 *
 * @see CMAPICredentials
 */
- (id)init;

/**
 * Note that you must have already initialized the
 * <tt>CMAPICredentials</tt> singleton with your app identifier and secret key.
 * Using this method will not tie this store to any particular user, and all objects
 * you retrieve and upload will be app-level.
 *
 * @param url The base URL you want this CMStore to interact with. This defaults to the CloudMine
 * base URL by default.
 * @see CMAPICredentials
 */
- (id)initWithBaseURL:(NSString *)url;

/**
 * Constructor that configures this store with a user.
 * Note that you must have already initialized the <tt>CMAPICredentials</tt> singleton
 * with your app identifier and secret key.
 *
 * @param theUser The user to configure the store with.
 *
 * @see CMAPICredentials
 * @see CMUser
 */
- (id)initWithUser:(CMUser *)theUser;

/**
 * Constructor that configures this store with a user.
 * Note that you must have already initialized the <tt>CMAPICredentials</tt> singleton
 * with your app identifier and secret key.
 *
 * @param theUser The user to configure the store with.
 * @param url The base URL you want this CMStore to interact with. This defaults to the CloudMine
 * base URL by default.
 *
 * @see CMAPICredentials
 * @see CMUser
 */
- (id)initWithUser:(CMUser *)theUser baseURL:(NSString *)url;

/**
 * Registers your application for push notifications. This method will contact Apple, request a token, handle the token
 * and register your application with CloudMine. After the token has been sent to Cloudmine, the callback with the result
 * will be given.
 *
 * <strong>Note</strong> - This method will register the stored CMUser to the token. If you do not want to associate the token with the user use
 * registerForPushNotifications:user:callback: and pass nil.
 *
 * @param notificationType The parameter of this method takes a UIRemoteNotificationType bit mask that specifies the initial types of notifications that the application wishes to receive. For example, <tt>(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)</tt>
 * @param callback Can be nil - The callback which is called once the Token has been sent to Cloudmine, returns the result of that transaction.
 */
- (void)registerForPushNotifications:(UIRemoteNotificationType)notificationType callback:(CMWebServiceDeviceTokenCallback)callback;

/**
 * Registers your application for push notifications. This method will contact Apple, request a token, handle the token
 * and register your application with CloudMine. After the token has been sent to Cloudmine, the callback with the result
 * will be given.
 *
 *
 * @param notificationType The parameter of this method takes a UIRemoteNotificationType bit mask that specifies the initial types of notifications that the application wishes to receive. For example, <tt>(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)</tt>
 * @param user Can be nil. The user you want to associate the token with.
 * @param callback Can be nil - The callback which is called once the Token has been sent to Cloudmine, returns the result of that transaction.
 */
- (void)registerForPushNotifications:(UIRemoteNotificationType)notificationType user:(CMUser *)aUser callback:(CMWebServiceDeviceTokenCallback)callback;

/**
 * Unregisters the users token from CloudMine, so they will no longer receive push notifications. Recommended to remove the token when
 * the user logs out of the app, but not required.
 *
 * @param callback Can be nil - The callback which is called once the Token has been removed fromCloudmine, returns the result of that transaction.
 */
- (void)unRegisterForPushNotificationsWithCallback:(CMWebServiceDeviceTokenCallback)callback;


/**
 * Downloads all app-level objects for your app's CloudMine object store.
 *
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @see CMStoreOptions
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
 */
- (void)allUserObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Downloads all ACLs associated with the store's user
 *
 * @param callback The callback to be triggered when all the ACLs are finished downloading. The store must be configured
 * with a user or else calling this method will throw an exception.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMACL
 */
- (void)allACLs:(CMStoreACLFetchCallback)callback;

/**
 * Downloads app-level objects for your app's CloudMine object store with the given keys.
 *
 * @param keys The keys of the objects you wish to download. Specifying a key for an object that does not exist will <b>not</b> cause an error.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @see CMStoreOptions
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
 */
- (void)userObjectsWithKeys:(NSArray *)keys additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Downloads app-level objects of the given class from your app's CloudMine object store.
 *
 * @param klass The class of the objects you want to download. <tt>[klass className]</tt> is called to determine the remote type.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>
 * @param callback The callback to be triggered when all the objects are finished downloading.>.
 *
 * @throws NSException An exception will be raised if <tt>klass</tt> doesn't respond to <tt>className</tt>.
 *
 * @see CMStoreOptions
 * @see CMSerializable#className
 */
- (void)allObjectsOfClass:(Class)klass additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Downloads user-level objects of the given class from your app's CloudMine object store. The store must be configured
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
 */
- (void)allUserObjectsOfClass:(Class)klass additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Performs a search across all app-level objects in your app's CloudMine object store.
 *
 * @param query The search query to perform. This must conform to the syntax outlined in the CloudMine <a href="https://cloudmine.me/docs/api#query_syntax" target="_blank">documentation</a>.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/docs/api#query_syntax
 */
- (void)searchObjects:(NSString *)query additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Performs a search across all user-level objects in your app's CloudMine object store. The store must be configured
 * with a user or else calling this method will throw an exception.
 *
 * @param query The search query to perform. This must conform to the syntax outlined in the CloudMine <a href="https://cloudmine.me/docs/api#query_syntax" target="_blank">documentation</a>.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when all the objects are finished downloading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMStoreOptions
 * @see https://cloudmine.me/docs/api#query_syntax
 */
- (void)searchUserObjects:(NSString *)query additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback;

/**
 * Performs a search across all ACLs owned by the user of the store The store must be configured
 * with a user or else calling this method will throw an exception.
 *
 * @param query The search query to perform. This must conform to the syntax outlined in the CloudMine <a href="https://cloudmine.me/docs/api#query_syntax" target="_blank">documentation</a>.
 * @param callback The callback to be triggered when all the ACLs are finished downloading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMACL
 * @see https://cloudmine.me/docs/api#query_syntax
 */
- (void)searchACLs:(NSString *)query callback:(CMStoreACLFetchCallback)callback;

/**
 * Downloads an app-level binary file from your app's CloudMine data store.
 *
 * @param callback The callback to be triggered when the file is finished downloading.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param name The unique name of the file to download.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)fileWithName:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileFetchCallback)callback;

/**
 * Downloads a user-level binary file from your app's CloudMine data store. The store must be configured
 * with a user or else calling this method will throw an exception.
 *
 * @param callback The callback to be triggered when the file is finished downloading.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param name The unique name of the file to download.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)userFileWithName:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileFetchCallback)callback;

/**
 * Saves all the objects (user- and app-level) in the store with your app's CloudMine data store. User-level objects
 * will only be sync'd if there is a user associated with this store.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 */
- (void)saveAll:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the objects (user- and app-level) in the store with your app's CloudMine data store. User-level objects
 * will only be sync'd if there is a user associated with this store.
 *
 * @param options Use these options to specify a server-side function to call after persisting the objects. Only CMStoreOptions#serverSideFunction is used.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 */
- (void)saveAllWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the app-level objects in the store to your app's CloudMine data store.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 */
- (void)saveAllAppObjects:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the app-level objects in the store to your app's CloudMine data store.
 *
 * @param options Use these options to specify a server-side function to call after persisting the objects. Only CMStoreOptions#serverSideFunction is used.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 */
- (void)saveAllAppObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the user-objects in the store to your app's CloudMine data store. The store must be configured
 * with a user or else calling this method will throw an exception.
 *
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
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
 */
- (void)saveAllUserObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the ACLs in the local store to CloudMine. The store must be configured
 * with a user or else calling this method will throw an exception.
 *
 * @param callback The callback to be triggered when all the ACLs are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMACL
 */
- (void)saveAllACLs:(CMStoreObjectUploadCallback)callback;

/**
 * Saves an individual object to your app's CloudMine data store at the app-level. If this object doesn't
 * already belong to this store, it will automatically be added as well. This has the additional effect of increasing
 * the object's retain count by 1 as well as setting its <tt>store</tt> property to this store.
 *
 * @param theObject The object to save.
 * @param callback The callback to be triggered when all the objects are finished uploading.
 *
 * @see CMObject#store
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
 */
- (void)saveUserObject:(CMObject *)theObject additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves an individual ACL to CloudMine's data store. The store must be configured with a user or else calling
 * this method will throw an exception. If this ACL doesn't already belong to this store, it will
 * automatically be added as well. This has the additional effect of increasing
 * the ACL's retain count by 1 as well as setting its <tt>store</tt> property to this store.
 *
 * @param acl The ACL to save.
 * @param callback The callback to be triggered when all the ACLs are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMACL
 */
- (void)saveACL:(CMACL *)acl callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves an array of ACLs to CloudMine's data store. The store must be configured with a user or else calling
 * this method will throw an exception. If the ACLs doesn't already belong to this store, it will
 * automatically be added as well. This has the additional effect of increasing
 * the ACLs' retain counts by 1 as well as setting their <tt>store</tt> property to this store.
 *
 * @param acls The ACLs to save.
 * @param callback The callback to be triggered when all the ACLs are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMACL
 */
- (void)saveACLs:(NSArray *)acls callback:(CMStoreObjectUploadCallback)callback;

/**
 * Saves all the ACLs in the store that are associated to the given object. The store must be configured with
 * a user or else calling this method will throw an exception. If the ACLs doesn't already belong to
 * this store, it will automatically be added as well. This has the additional effect of increasing
 * the ACLs' retain counts by 1 as well as setting their <tt>store</tt> property to this store.
 *
 * @param object The object whose ACLs will be saved
 * @param callback The callback to be triggered when all the ACLs are finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMACL
 */
- (void)saveACLsOnObject:(CMObject *)object callback:(CMStoreObjectUploadCallback)callback;

/**
 * Deletes the given app-level object from your app's CloudMine data store and removes the object from this store.
 * This also triggers a notification of type <tt>CMStoreObjectDeletedNotification</tt> to subscribers of the store
 * so you can do any other necessary cleanup throughout your app. This notification is triggered <b>before</b> the object
 * is deleted from the server.
 *
 * @param theObject The object to delete and remove from the store.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered after the object has been deleted.
 */
- (void)deleteObject:(id<CMSerializable>)theObject additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the app-level. This works by streaming the contents of the
 * file directly from the filesystem, thus never loading the file into memory. The server will generate a name for this file,
 * which will be passed into the given callback.
 *
 * @param url The absolute URL to the location of the file on the device.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file is finished uploading.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)saveFileAtURL:(NSURL *)url additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the app-level. This works by streaming the contents of the
 * file directly from the filesystem, thus never loading the file into memory. You must give the file a name that is
 * unique within your app's data store.
 *
 * @param url The absolute URL to the location of the file on the device.
 * @param name The name to give the file on CloudMine. <b>This must be unique throughout all instances of your app.</b>
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file is finished uploading.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)saveFileAtURL:(NSURL *)url named:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the user-level. The store must be configured
 * with a user or else calling this method will throw an exception. This works by streaming the contents of the
 * file directly from the filesystem, thus never loading the file into memory. The server will generate a name for this file,
 * which will be passed into the given callback.
 *
 * @param url The absolute URL to the location of the file on the device.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file is finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)saveUserFileAtURL:(NSURL *)url additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the user-level. The store must be configured
 * with a user or else calling this method will throw an exception. This works by streaming the contents of the
 * file directly from the filesystem, thus never loading the file into memory. You must give the file a name that is
 * unique within your app's data store.
 *
 * @param url The absolute URL to the location of the file on the device.
 * @param name The name to give the file on CloudMine. <b>This must be unique throughout all instances of your app.</b>
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file is finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)saveUserFileAtURL:(NSURL *)url named:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the app-level. This uses the raw data of the file's contents
 * contained in an <tt>NSData</tt> object. The server will generate a name for this file, which will be passed into the given callback.
 *
 * @param data The raw contents of the file.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file is finished uploading.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)saveFileWithData:(NSData *)data additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the app-level. This uses the raw data of the file's contents
 * contained in an <tt>NSData</tt> object. You must give the file a name that is unique within your app's data store.
 *
 * @param data The raw contents of the file.
 * @param name The name to give the file on CloudMine. <b>This must be unique throughout all instances of your app.</b>
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file is finished uploading.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)saveFileWithData:(NSData *)data named:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the user-level. The store must be configured
 * with a user or else calling this method will throw an exception. This uses the raw data of the file's contents
 * contained in an <tt>NSData</tt> object. The server will generate a name for this file, which will be passed into
 * the given callback.
 *
 * @param data The raw contents of the file.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file is finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)saveUserFileWithData:(NSData *)data additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback;

/**
 * Saves a file to your app's CloudMine data store at the user-level. The store must be configured
 * with a user or else calling this method will throw an exception. This uses the raw data of the file's contents
 * contained in an <tt>NSData</tt> object. You must give the file a name that is unique within your app's data store.
 *
 * @param data The raw contents of the file.
 * @param name The name to give the file on CloudMine. <b>This must be unique throughout all instances of your app.</b>
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file is finished uploading.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)saveUserFileWithData:(NSData *)data named:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback;

/**
 * Deletes the given app-level file from your app's CloudMine data store.
 *
 * @param name The name of the file to delete.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file has been deleted.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)deleteFileNamed:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes the given user-level file from your app's CloudMine data store. The store must be configured
 * with a user or else calling this method will throw an exception.
 *
 * @param name The name of the file to delete.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the file has been deleted.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see https://cloudmine.me/docs/ios/reference#app_files
 */
- (void)deleteUserFileNamed:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes the given user-level object from your app's CloudMine data store and removes the object from this store. The store must be configured
 * with a user or else calling this method will throw an exception.
 * This also triggers a notification of type <tt>CMStoreObjectDeletedNotification</tt> to subscribers of the store
 * so you can do any other necessary cleanup throughout your app. This notification is triggered <b>before</b> the object
 * is deleted from the server.
 *
 * @param theObject The object to delete and remove from the store.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the object has been deleted.
 */
- (void)deleteUserObject:(id<CMSerializable>)theObject additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes the given ACL from CloudMine's data store and removes the acl from this store. The store must be configured
 * with a user or else calling this method will throw an exception. The ACL will automatically remove references to itself from
 * __access__ fields of the objects it belonged to.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @param acl The ACL to delete and remove from the store.
 * @param callback The callback to be triggered when the acl has been deleted.
 */
- (void)deleteACL:(CMACL *)acl callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes all the given app-level objects from your app's CloudMine data store and removes the object from this store.
 * This also triggers a notification of type <tt>CMStoreObjectDeletedNotification</tt> to subscribers of the store
 * so you can do any other necessary cleanup throughout your app. This notification is triggered <b>before</b> the objects
 * are deleted from the server.
 *
 * @param objects The objects to delete and remove from the store.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the objects have been deleted.
 */
- (void)deleteObjects:(NSArray *)objects additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes all the given user-level objects from your app's CloudMine data store and removes the object from this store. The store must be configured
 * with a user or else calling this method will throw an exception.
 * This also triggers a notification of type <tt>CMStoreObjectDeletedNotification</tt> to subscribers of the store
 * so you can do any other necessary cleanup throughout your app. This notification is triggered <b>before</b> the objects
 * are deleted from the server.
 *
 * @param objects The objects to delete and remove from the store.
 * @param options Additional options, such as paging and server-side post-processing functions, to apply. This can be <tt>nil</tt>.
 * @param callback The callback to be triggered when the objects has been deleted.
 */
- (void)deleteUserObjects:(NSArray *)objects additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback;

/**
 * Deletes the given ACLs from CloudMine's data store and removes them from this store. The store must be configured
 * with a user or else calling this method will throw an exception. The ACLs will automatically remove references to themselves from
 * __access__ fields of the objects it belonged to.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @param acls The ACLs to delete and remove from the store.
 * @param callback The callback to be triggered when the acl has been deleted.
 */
- (void)deleteACLs:(NSArray *)acls callback:(CMStoreDeleteCallback)callback;

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
 */
- (void)addUserObject:(CMObject *)theObject;

/**
 * Adds an ACL to this store. Doing this also sets the ACL's <tt>store</tt> property to this store.
 * No persistence is performed as a result of calling this method. The store must be configured
 * with a user or else calling this method will throw an exception. <b>This method is thread-safe</b>.
 *
 * @param acl The object to add.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMACL
 */
- (void)addACL:(CMACL *)acl;

/**
 * Removes an app-level object from this store. Doing this also nullifies the object's <tt>store</tt> property.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param theObject The object to remove.
 *
 * @see CMObject#store
 */
- (void)removeObject:(CMObject *)theObject;

/**
 * Removes a user-level object from this store. The store must be configured with a user or else calling this method will throw an exception.
 * Doing this also nullifies the object's <tt>store</tt> property.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param theObject The object to remove.
 *
 * @see CMObject#store
 */
- (void)removeUserObject:(CMObject *)theObject;

/**
 * Removes an ACL from this store. The store must be configured with a user or else calling this method will throw an exception.
 * Doing this also nullifies the object's <tt>store</tt> property.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param acl The object to remove.
 *
 * @see CMACL
 */
- (void)removeACL:(CMACL *)acl;

/**
 * Adds an app-level file to this store. Doing this also sets the file's <tt>store</tt> property to this store.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param theFile The file to add.
 *
 * @see CMObject#store
 */
- (void)addFile:(CMFile *)theFile;

/**
 * Adds a user-level file to this store. Doing this also sets the file's <tt>store</tt> property to this store.
 * No persistence is performed as a result of calling this method. The store must be configured
 * with a user or else calling this method will throw an exception. <b>This method is thread-safe</b>.
 *
 * @param theFile The file to add.
 *
 * @throws NSException An exception will be raised if this method is called when a user is not configured for this store.
 *
 * @see CMObject#store
 */
- (void)addUserFile:(CMFile *)theFile;

/**
 * Removes an app-level file from this store. Doing this also nullifies the file's <tt>store</tt> property.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param theFile The file to remove.
 *
 * @see CMObject#store
 */
- (void)removeFile:(CMFile *)theFile;

/**
 * Removes a user-level file from this store. The store must be configured with a user or else calling this method will throw an exception.
 * Doing this also nullifies the file's <tt>store</tt> property.
 * No persistence is performed as a result of calling this method. <b>This method is thread-safe</b>.
 *
 * @param theFile The file to remove.
 *
 * @see CMObject#store
 */
- (void)removeUserFile:(CMFile *)theFile;

/**
 * @param theObject An instance of CMObject or CMFile.
 * @return The ownership level of the object or file given.
 * @see CMObjectOwnershipLevel
 */
- (CMObjectOwnershipLevel)objectOwnershipLevel:(id)theObject;

@end
