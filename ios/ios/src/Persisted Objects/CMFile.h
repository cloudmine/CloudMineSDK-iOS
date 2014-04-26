//
//  CMFile.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMSerializable.h"
#import "CMObjectOwnershipLevel.h"
#import "CMStoreCallbacks.h"

@class CMUser;
@class CMStore;

@interface CMFile : NSObject <CMSerializable>

/**
 * The raw data of the file.
 */
@property (atomic, strong, readonly) NSData *fileData;

/**
 * A human-readable filename. This is how you will perform requests for specific files.
 */
@property (nonatomic, strong) NSString *fileName;

/**
 * The automatically computed location of where the filesyste cache of this file will be stored.
 */
@property (nonatomic, readonly) NSURL *cacheLocation;

/**
 * The user who owns this file.
 */
@property (nonatomic, readonly) CMUser *user;

/**
 * The MIME type of this file. This SDK comes with a built-in dictionary of common MIME types. You can
 * look up a MIME type via its file extension using CMMimeType#mimeTypeForExtension:
 * Defaults to "application/octet-stream".
 */
@property (nonatomic, strong) NSString *mimeType;

/**
 * The unique identifier for this file. This is used to ensure caches on the filesystem don't stomp each other.
 * This is auto-generated.
 */
@property (nonatomic, readonly) NSString *uuid;

/**
 * The store that the file belongs to. If you have not explicitly assigned this file to a store, it
 * will automatically belong to CMStore#defaultStore.
 *
 * If you manually change the store yourself, this file will automatically remove itself from the old
 * store and add it to the new store. <b>This operation is thread-safe.</b>
 */
@property (nonatomic, assign) CMStore *store;

/**
 * The ownership level of this object. This reflects whether the object is app-level, user-level, or unknown.
 * @see CMObjectOwnershipLevel
 */
@property (nonatomic, readonly) CMObjectOwnershipLevel ownershipLevel;

/**
 * Creates a new file instance with data and a MIME type of <tt>application/octet-stream</tt>.
 *
 * @param theFileData The file's raw data.
 * @param theName The human-readable name of the file. This must be unique in your app, just like when there are many files in the same directory on a filesystem.
 */
- (id)initWithData:(NSData *)theFileData named:(NSString *)theName;

/**
 * Creates a new file instance with data.
 *
 * @param theFileData The file's raw data.
 * @param theName The human-readable name of the file. This must be unique in your app, just like when there are many files in the same directory on a filesystem.
 * @param theMimeType The MIME type of this file. Common MIME types keyed on file extensions can be accessed via CMMimeType#mimeTypeForExtension:. Defaults to <tt>application/octet-stream</tt>.
 */
- (id)initWithData:(NSData *)theFileData named:(NSString *)theName mimeType:(NSString *)theMimeType;

/**
 * @deprecated
 * Modifying the owner of a CMFile directly is no longer supported. Instead, go through CMStore as you would
 * for managing ownership of CMObject instances.
 *
 * The non-deprecated constructor to use is CMFile#initWithData:named:mimeType:.
 */
- (id)initWithData:(NSData *)theFileData named:(NSString *)theName belongingToUser:(CMUser *)theUser mimeType:(NSString *)theMimeType __attribute__((deprecated));

/**
 * @deprecated
 * Use CMFile#ownershipLevel instead.
 */
- (BOOL)isUserLevel __attribute__((deprecated));

/**
 * Writes this object to a specific filesystem location. <strong>You typically shouldn't need to invoke this method yourself.</strong>
 *
 * @param url The NSURL of the location on the filesystem to write the file.
 * @param options File writing options.
 * @return <tt>YES</tt> if the write operation was successful, <tt>NO</tt> otherwise.
 */
- (BOOL)writeToLocation:(NSURL *)url options:(NSFileWrapperWritingOptions)options;

/**
 * Writes this object to the cache location on the filesystem. This location is determined automatically depending on whether the file belongs to a user
 * or not, the type and size of the file, etc. <strong>You typically shouldn't need to invoke this method yourself.</strong>
 * @return <tt>YES</tt> if the write was successful, <tt>NO</tt> otherwise.
 */
- (BOOL)writeToCache;

/**
 * Saves this file to CloudMine using its current store.
 * If this file does not belong to a store, the default store will be used. It will be added at the app-level. If you need to
 * associate this file with a user, see CMObject#saveWithUser:callback:.
 *
 * If this file already belongs to a store, it will be saved to the app- or user-level, whichever it was added as. For example, if it was
 * originally added to a store using CMStore#addFile: or CMStore#saveFile:: (i.e. at the app-level) it will be saved at the app-level. If it was
 * originally added using CMStore#addUserFile:callback:, CMStore#saveUserFile:callback:, or CMFile#saveWithUser:callback: (i.e. at the user-level) it will be saved
 * at the user-level.

 * @param callback The callback block to be invoked after the save operation has completed.
 *
 * @see CMStore#defaultStore
 */
- (void)save:(CMStoreFileUploadCallback)callback;

/**
 * Saves this file to CloudMine at the user-level associated with the given user.
 * If this file does not belong to a store, the default store will be used.
 *
 * <b>Note:</b> If this file has already been added to a store at the app-level, it cannot be later
 * saved at the user-level. You must duplicate the file, change its CMFile#objectId, and then add it
 * at the user-level.
 *
 * @param user The user to associate this file with.
 * @param callback The callback block to be invoked after the save operation has completed.
 */
- (void)saveWithUser:(CMUser *)user callback:(CMStoreFileUploadCallback)callback;

@end
