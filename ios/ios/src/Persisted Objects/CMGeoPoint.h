//
//  CMGeoPoint.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <CoreLocation/CoreLocation.h>
#include <math.h>
#import "CMObject.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CMGeoPointClassName;

@interface CMGeoPoint : CMObject

/**
 * Initializes a new instance of this class with the given latitude and longitude.
 *
 * @param theLatitude The latitude in <strong>degrees</strong>.
 * @param theLongitude The longitude in <strong>degrees</strong>.
 */
- (instancetype)initWithLatitude:(double)theLatitude andLongitude:(double)theLongitude NS_DESIGNATED_INITIALIZER;

/**
 * Initializes a new instance of this class with the given latitude and longitude.
 *
 * This is a convenience constructor for when lat/long are in radians. This converts them
 * into degrees before storing.
 *
 * @param theLatitude The latitude in <strong>radians</strong>.
 * @param theLongitude The longitude in <strong>radians</strong>.
 */
- (instancetype)initWithLatitudeInRadians:(double)theLatitude andLongitudeInRadians:(double)theLongitude;

/**
 * Initializes a new instance of this class given a <tt>CLLocation</tt> object most likely obtained from
 * <tt>CLLocationManager</tt> or some other part of the CoreLocation framework.
 *
 * @param location The <tt>CLLocation</tt> instance describing the location.
 *
 * @see https://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CLLocation_Class/CLLocation/CLLocation.html
 * @see https://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/LocationAwarenessPG/Introduction/Introduction.html
 */
- (instancetype)initWithCLLocation:(CLLocation *)location;

- (instancetype)initWithObjectId:(NSString *)theObjectId NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * The latitude in degrees.
 */
@property (atomic, assign) double latitude;

/**
 * The longitude in degrees.
 */
@property (atomic, assign) double longitude;

@end

NS_ASSUME_NONNULL_END
