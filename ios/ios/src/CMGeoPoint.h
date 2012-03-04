//
//  CMGeoPoint.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <CoreLocation/CoreLocation.h>
#include <math.h>
#import "CMObject.h"

extern NSString * const CMGeoPointClassName;

@interface CMGeoPoint : CMObject {

}

/**
 * Initializes a new instance of this class with the given latitude and longitude.
 *
 * @param theLatitude The latitude in <strong>degrees</strong>.
 * @param theLongitude The longitude in <strong>degrees</strong>.
 */
- (id)initWithLatitude:(double)theLatitude andLongitude:(double)theLongitude;

/**
 * Initializes a new instance of this class with the given latitude and longitude.
 *
 * This is a convenience constructor for when lat/long are in radians. This converts them
 * into degrees before storing.
 *
 * @param theLatitude The latitude in <strong>radians</strong>.
 * @param theLongitude The longitude in <strong>radians</strong>.
 */
- (id)initWithLatitudeInRadians:(double)theLatitude andLongitudeInRadians:(double)theLongitude;

/**
 * Initializes a new instance of this class given a <tt>CLLocation</tt> object most likely obtained from
 * <tt>CLLocationManager</tt> or some other part of the CoreLocation framework.
 *
 * @param location The <tt>CLLocation</tt> instance describing the location.
 *
 * @see https://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CLLocation_Class/CLLocation/CLLocation.html
 * @see https://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/LocationAwarenessPG/Introduction/Introduction.html
 */
- (id)initWithCLLocation:(CLLocation *)location;

/**
 * The latitude in degrees.
 */
@property (atomic, assign) double latitude;

/**
 * The longitude in degrees.
 */
@property (atomic, assign) double longitude;

@end
