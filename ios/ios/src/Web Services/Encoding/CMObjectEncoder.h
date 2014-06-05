//
//  CMObjectDecoder.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * Encodes objects and scalar values into a dictionary form. This is meant for simple domain model relationships
 * and should not be considered as general purpose as <tt>NSArchiver</tt> and <tt>NSUnarchiver</tt>, which
 * can be used easily to serialize entire user interfaces.
 *
 * Other than that note, this works the exact same way as standard Cocoa object serialization and deserailization
 * works. Just implement <tt>NSCoding</tt> on your class and respond to the two methods.
 *
 * <strong>Note:</strong> You cannot use this class directly to serialize objects to be sent over the wire. You must
 * use one of its subclasses appropriate for the particular over-the-wire format you would like to use.
 */
@interface CMObjectEncoder : NSCoder {
    NSMutableDictionary *_encodedData;
}

/**
 * The encoded representation of the object. This will be an <tt>NSDictionary</tt> in <tt>CMObjectEncoder</tt>
 * and an encoding-method-specific type for subclasses.
 *
 * This <strong>MUST</strong> be overridden in subclasses. When serializing an object it cannot be sent as
 * an instance of an <tt>NSDictionary</tt> and subclasses of this must take care of that conversion.
 *
 * @return NSDictionary
 */
@property (atomic, readonly) id encodedRepresentation;

/**
 * Kicks off the encoding process for a collection of objects that implement <tt>CMSerializable</tt>.
 *
 * This return type should be the same as for <tt>encodedRepresentation</tt>. Calling this method kicks off
 * the entire encoding process and returns the final encoded value. Subclasses <strong>MUST</strong> override
 * this method for reasons outlined in the description for <tt>encodedRepresentation</tt>.
 *
 * @see CMSerializable
 * @see encodedRepresentation
 *
 * @param objects The objects to encode.
 * @return NSDictionary
 */
+ (NSDictionary *)encodeObjects:(id<NSFastEnumeration>)objects;

@end
