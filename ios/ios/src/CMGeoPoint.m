//
//  CMGeoPoint.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMGeoPoint.h"

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

#pragma mark - Serialization methods

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];
}

+ (NSString *)className {
    return CMGeoPointClassName;
}

#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    } else {
        return (self.latitude == [object latitude] && self.longitude == [object longitude]);
    }
}

@end
