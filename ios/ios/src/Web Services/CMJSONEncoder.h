//
//  CMJSONEncoder.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * Encodes objects and scalar values into JSON. This is meant for simple domain model relationships
 * and should not be considered as general purpose as <tt>NSArchiver</tt> and <tt>NSUnarchiver≤/tt>, which
 * can be used easily to serialize entire user interfaces.
 *
 * Other than that note, this works the exact same way as standard Cocoa object serialization and deserailization
 * works. Just implement <tt>NSCoding</tt> on your class and respond to the two methods.
 */
@interface CMJSONEncoder : NSCoder {
    NSMutableDictionary *_encodedData;
}

@property (readonly) NSDictionary *jsonRepresentation;
@property (readonly) NSData *jsonData;

+ (NSData *)serializeObjects:(id<NSFastEnumeration>)objects;

@end
