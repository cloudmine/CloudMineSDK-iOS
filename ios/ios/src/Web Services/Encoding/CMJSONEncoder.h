//
//  CMJSONEncoder.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <YAJLiOS/YAJL.h>

#import "CMObjectEncoder.h"

/**
 * Encodes objects and scalar values into JSON form. This is meant for simple domain model relationships
 * and should not be considered as general purpose as <tt>NSArchiver</tt> and <tt>NSUnarchiver</tt>, which
 * can be used easily to serialize entire user interfaces.
 *
 * Other than that note, this works the exact same way as standard Cocoa object serialization and deserailization
 * works. Just implement <tt>NSCoding</tt> on your class and respond to the two methods.
 *
 * @see CMObjectEncoder
 */
@interface CMJSONEncoder : CMObjectEncoder

/**
 * An <tt>NSString</tt> containing the JSON representation of the encoded objects.
 */
@property (atomic, readonly) id encodedRepresentation;

/**
 * Kicks off the encoding process for each of <tt>objects</tt> and returns a string containing
 * the JSON representation of all the serialized objects that can be subsequently sent over the wire to
 * CloudMine's web services.
 *
 * @param objects
 * @returns The JSON representation of the objects, ready to be sent to CloudMine.
 */
+ (NSString *)encodeObjects:(id<NSFastEnumeration>)objects;

@end
