//
//  CMGeoPoint.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMGeoPoint.h"
#import "CMObjectSerialization.h"
#import "float.h"

#ifndef FLT_EPSILON
    #define FLT_EPSILON __FLT_EPSILON__
#endif

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

NSString * const CMGeoPointClassName = @"geopoint";

@implementation CMGeoPoint

@synthesize latitude;
@synthesize longitude;

#pragma - Initialization and deserialization

- (id)initWithLatitude:(double)theLatitude andLongitude:(double)theLongitude {
    if (self = [super init]) {
        self.latitude = theLatitude;
        self.longitude = theLongitude;
    }
    return self;
}

- (id)initWithLatitudeInRadians:(double)theLatitude andLongitudeInRadians:(double)theLongitude {
    const double radianMultiplier = 180 / M_PI;
    return [self initWithLatitude:theLatitude*radianMultiplier andLongitude:theLongitude*radianMultiplier];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithLatitude:[aDecoder decodeDoubleForKey:@"latitude"]
                     andLongitude:[aDecoder decodeDoubleForKey:@"longitude"]];
}

- (id)initWithCLLocation:(CLLocation *)location {
    return [self initWithLatitude:location.coordinate.latitude
                     andLongitude:location.coordinate.longitude];
}

#pragma mark - Serialization methods

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:CMGeoPointClassName forKey:CMInternalTypeStorageKey];
}

#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    } else {
        return (fequal(self.latitude, [object latitude]) && fequal(self.longitude, [object longitude]));
    }
}

@end
