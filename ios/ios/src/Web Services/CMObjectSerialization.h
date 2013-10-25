//
//  CMObjectSerialization.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/**
 * Constants and enums used across the various encoding and decoding classes.
 */

/**
 * To distinguish between dictionary representation and an actual dictionary object
 * on the client side, this special classname is used to represent the latter.
 */
#define CMInternalHashClassName @"map"

/**
 * The key to be used to store the special CloudMine type of an object when serializing it
 * into a dictionary. Note that this does not correspond to the class of the object being serialized.
 * It is used exclusively for objects treated as special for one reason or another by CloudMine. One
 * example of this is the type "geopoint", which is geospatially indexed automatically by CloudMine.
 */
#define CMInternalTypeStorageKey @"__type__"

/**
 * The key to be used to store the class name of an object when serializing it
 * into a dictionary. This will be used on deserialization to instantiate the
 * correct type of object.
 */
#define CMInternalClassStorageKey @"__class__"

/**
 * The key to be used to store the id of the object being serialized. The value of this
 * becomes the key of the object's representation in dictionary form.
 */
#define CMInternalObjectIdKey @"__id__"

/**
 * The key to be used to store the array of ACL IDs attached to the object being serialized.
 */
#define CMInternalObjectACLsKey @"__access__"

/**
 * The key used to store services from linking accounts with social networks
 */
#define CMInternalServiceStorageKey @"__services__"

/**
 * A set of all the object keys used internally by this framework for (de)serialization purposes.
 */
#define CMInternalKeys [NSSet setWithObjects:CMInternalTypeStorageKey, CMInternalClassStorageKey, CMInternalObjectIdKey, CMInternalObjectACLsKey, CMInternalServiceStorageKey, nil]
