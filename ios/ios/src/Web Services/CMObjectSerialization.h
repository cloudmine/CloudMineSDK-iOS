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
#define CM_INTERNAL_HASH_CLASSNAME @"map"

/**
 * The key to be used to store the class name of an object when serializing it
 * into a dictionary. This will be used on deserialization to instantiate the
 * correct type of object.
 */
#define CM_INTERNAL_TYPE_STORAGE_KEY @"__type__"