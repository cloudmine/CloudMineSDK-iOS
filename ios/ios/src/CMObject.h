//
//  CMObject.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMSerializable.h"

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
 * Initializes this object by generating a UUID as the default value for <tt>objectId</tt>.
 */
- (id)init;

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

@end
