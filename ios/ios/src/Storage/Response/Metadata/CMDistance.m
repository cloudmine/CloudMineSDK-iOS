//
//  CMDistance.m
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMDistance.h"

NSString * const CMIncludeDistanceKey = @"distance";
NSString * const CMDistanceUnitsKey   = @"units";

NSString * const CMDistanceUnitsKm = @"km";
NSString * const CMDistanceUnitsMi = @"mi";
NSString * const CMDistanceUnitsM  = @"m";
NSString * const CMDistanceUnitsFt = @"ft";

@implementation CMDistance

- (instancetype)initWithDistance:(double)theDistance andUnits:(NSString *)theUnits
{
    NSAssert(nil != theUnits, @"Must provide units to CMDistance");

    self = [super init];
    if (nil == self) return nil;

    _distance = theDistance;
    _units = theUnits;

    return self;
}

@end
