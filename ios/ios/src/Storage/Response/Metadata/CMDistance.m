//
//  CMDistance.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMDistance.h"

NSString * const CMIncludeDistanceKey = @"distance";
NSString * const CMDistanceUnitsKey = @"units";

NSString * const CMDistanceUnitsKm = @"km";
NSString * const CMDistanceUnitsMi = @"mi";
NSString * const CMDistanceUnitsM = @"m";
NSString * const CMDistanceUnitsFt = @"ft";

@implementation CMDistance

@synthesize distance;
@synthesize units;

- initWithDistance:(double)theDistance andUnits:(NSString *)theUnits {
    if(self = [super init]) {
        distance = theDistance;
        units = theUnits;
    }

    return self;
}

@end
