//
//  CMObjectSerialization.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
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
 * The key to be used to store the class name of an object when serializing it
 * into a dictionary. This will be used on deserialization to instantiate the
 * correct type of object.
 */
#define CMInternalTypeStorageKey @"__type__"

/**
 * The key to be used to store the id of the object being serialized. The value of this
 * becomes the key of the object's representation in dictionary form.
 */
#define CMInternalObjectIdKey @"__id__"