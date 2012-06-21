//
//  CMObject.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMSerializable.h"
#import "CMStoreCallbacks.h"
#import "CMUser.h"
#import "CMStore.h"

/**
 * Extend from this instead of <tt>NSObject</tt> for all model objects in your app that need to be backed
 * by remote storage on CloudMine. Be sure to implement <tt>initWithCoder:</tt> and <tt>encodeWithCoder:</tt>
 * in each of these model classes to define how to serialize and deserialize the object. This behavior follows
 * the standard archiving/unarchiving conventions defined by Apple's <tt>NSCoding</tt> protocol.
 *
 * This will also take care of generating a default <tt>objectId</tt> for you, in the form of a UUID.
 */
@interface CMObject : NSObject <CMSerializable>

/**
 * The store that the object belongs to. If you have not explicitly assigned this object to a store, it
 * will automatically belong to CMStore#defaultStore.
 *
 * If you manually change the store yourself, this object will automatically remove itself from the old
 * store and add it to the new store. <b>This operation is thread-safe.</b>
 */
@property (nonatomic, unsafe_unretained) CMStore *store;

/**
 * The ownership level of this object. This reflects whether the object is app-level, user-level, or unknown.
 * @see CMObjectOwnershipLevel
 */
@property (nonatomic, readonly) CMObjectOwnershipLevel ownershipLevel;

/**
 * Initializes this app-level object by generating a UUID as the default value for <tt>objectId</tt>.
 */
- (id)init;

/**
 * Initializes this app-level object with the given object ID. Note that this MUST be unique throughout your app.
 *
 * @param theObjectId The unique id of the object. This must be unique throughout the entire app.
 */
- (id)initWithObjectId:(NSString *)theObjectId;

/**
 * Default behavior does nothing other than call <tt>[self init]</tt>. Override this in your subclasses
 * to define logic for creating an instance of each subclass from a serialized representation.
 *
 * @see CMSerializable
 */
- (id)initWithCoder:(NSCoder *)aDecoder;

/**
 * Default behavior does nothing. Override this in your subclasses to define logic
 * for serializing instances of each subclass for remote storage.
 *
 * @see CMSerializable
 */
- (void)encodeWithCoder:(NSCoder *)aCoder;

/**
 * @deprecated
 * This method will always return <tt>YES</tt>. If no store has been explicitly assigned, the default store will be used.
 *
 * Note: The object must belong to a store if you need to save it. You can easily add the object to a store and
 * save it by using <tt>CMStore</tt>'s <tt>saveObject:</tt> method.
 *
 * @see CMStore
 * @return <tt>true</tt> if this object belongs to any store.
 */
- (BOOL)belongsToStore;

/**
 * Saves this object to CloudMine using its current store.
 * If this object does not belong to a store, the default store will be used. It will be added at the app-level. If you need to
 * associate this object with a user, see CMObject#saveWithUser:callback:.
 *
 * If this object already belongs to a store, it will be saved to the app- or user-level, whichever it was added as. For example, if it was
 * originally added to a store using CMStore#addObject: or CMStore#saveObject:: (i.e. at the app-level) it will be saved at the app-level. If it was
 * originally added using CMStore#addUserObject:callback:, CMStore#saveUserObject:callback:, or CMObject#saveWithUser:callback: (i.e. at the user-level) it will be saved
 * at the user-level.

 * @param callback The callback block to be invoked after the save operation has completed.
 *
 * @see CMStore#defaultStore
 */
- (void)save:(CMStoreObjectUploadCallback)callback;

/**
 * Saves this object to CloudMine at the user-level associated with the given user.
 * If this object does not belong to a store, the default store will be used.
 *
 * <b>Note:</b> If this object has already been added to a store at the app-level, it cannot be later
 * saved at the user-level. You must duplicate the object, change its CMObject#objectId, and then add it
 * at the user-level.
 *
 * @param user The user to associate this object with.
 * @param callback The callback block to be invoked after the save operation has completed.
 */
- (void)saveWithUser:(CMUser *)user callback:(CMStoreObjectUploadCallback)callback;

@end
