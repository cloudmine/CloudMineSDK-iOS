//
//  CMSerializable.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * Protocol that all objects must adhere to in order to communicate with CloudMine.
 */
@protocol CMSerializable <NSObject, NSCoding>

/**
 * Every object must have a form of unique identifier. Implement this
 * in the classes that implement this protocol to provide that identifier.
 */
@property (atomic, readonly, strong) NSString *objectId;

/**
 * The name of this class. This method must be overriden and implemented
 * for cross-platform reasons. Choose a name that is consistent across all the
 * platforms you are writing this app for (i.e. if all your Objective-C classes have
 * a two-letter prefix and your Java classes for your Android version do not, you may
 * want to stick with the non-prefixed class name for encoding and decoding purposes so
 * everything matches up in each version of your app).
 *
 * @return The name of the class.
 */
+ (NSString *)className;

@end
