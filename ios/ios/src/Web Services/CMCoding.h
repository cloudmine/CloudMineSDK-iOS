//
//  CMCoding.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/26/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Protocol that all objects must adhere to in order to communicate with CloudMine.
 */
@protocol CMCoding <NSObject, NSCoding>

@optional
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
