//
//  CMDistance.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CMDistanceUnitsKm;
extern NSString * const CMDistanceUnitsMi;
extern NSString * const CMDistanceUnitsM;
extern NSString * const CMDistanceUnitsFt;

extern NSString * const CMIncludeDistanceKey;
extern NSString * const CMDistanceUnitsKey;

/**
 * Container class for distance information returned from geospacial queries. Contains the distance as a double
 * and the units of that distance as a string.
 */
@interface CMDistance : NSObject

/**
 * Units of distance, valid values are "km", "mi", "ft", and "m".
 */
@property (nonatomic, readonly) NSString * units;

/**
 * Distance of this object from the given point.
 */
@property (nonatomic, readonly) double distance;

/**
 *  Initializes an instance of CMDistance.
 *
 * @param theDistance Measured distance
 * @param theUnits Associated units, see: CMDistanceUnits
 */
- (instancetype)initWithDistance:(double)theDistance andUnits:(NSString *)theUnits;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
