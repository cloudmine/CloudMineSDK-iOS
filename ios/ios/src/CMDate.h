//
//  CMDate.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import <Foundation/Foundation.h>
#import "CMSerializable.h"

extern NSString * const CMDateClassName;

/**
 * This class wraps <tt>NSDate</tt> so you can use it in your CloudMine-backed objects without
 * worrying about converting to and from timestamps on serialization and deserialization. It forwards
 * all instance methods to the <tt>NSDate</tt> instance it wraps and it subclasses the abstract <tt>NSDate</tt>
 * class so you can use it exactly as you would use an <tt>NSDate</tt>.
 */
@interface CMDate : NSDate <CMSerializable> {
    NSDate *_date;
}

@property (nonatomic, readonly) NSDate *date;

/**
 * Initialize this object with <tt>[NSDate date]</tt>, which will be intialized to the current date and time.
 */
- (id)init;

/**
 * Initialize this object with an arbitrary <tt>NSDate</tt>.
 */
- (id)initWithDate:(NSDate *)theDate;

@end
