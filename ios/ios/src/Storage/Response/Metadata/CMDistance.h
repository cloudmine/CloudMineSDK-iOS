//
//  CMDistance.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

extern NSString * const CMDistanceUnitsKm;
extern NSString * const CMDistanceUnitsMi;
extern NSString * const CMDistanceUnitsM;
extern NSString * const CMDistanceUnitsFt;

extern NSString * const CMIncludeDistanceKey;
extern NSString * const CMDistanceUnitsKey;

@interface CMDistance : NSObject

@property (strong, nonatomic, readonly) NSString * units;
@property (nonatomic, readonly) double distance;

- initWithDistance:(double)theDistance andUnits:(NSString *)theUnits;

@end
