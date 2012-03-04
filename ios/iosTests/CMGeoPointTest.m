//
//  CMGeoPointSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMGeoPoint.h"
#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"

@interface CMGeoTestingObject : CMObject
@property (strong) NSString *name;
@property (strong) CMGeoPoint *loc;
@end

@implementation CMGeoTestingObject
@synthesize name,loc;
- (id)init {
    self = [super init];
    if (self) {
        self.name = @"foo";
        self.loc = [[CMGeoPoint alloc] initWithLatitude:47.33 andLongitude:-72.394];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.loc = [aDecoder decodeObjectForKey:@"loc"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.loc forKey:@"loc"];
}
@end

SPEC_BEGIN(CMGeoPointSpec)

describe(@"CMGeoPoint", ^{
    it(@"should convert radians to degrees before storage if initialized with radians", ^{
        double latitudeInRadians = M_PI;
        double longitudeInRadians = M_PI_2;
        double latitudeInDegrees = 180;
        double longitudeInDegrees = 90;
        CMGeoPoint *point = [[CMGeoPoint alloc] initWithLatitudeInRadians:latitudeInRadians andLongitudeInRadians:longitudeInRadians];
        [[theValue(point.latitude) should] equal:theValue(latitudeInDegrees)];
        [[theValue(point.longitude) should] equal:theValue(longitudeInDegrees)];
    });

    it(@"should encode into a dictionary with latitude and longitude", ^{
        double lat = 47.33;
        double lon = -72.394;
        CMGeoPoint *point = [[CMGeoPoint alloc] initWithLatitude:lat andLongitude:lon];
        NSDictionary *serializedObject = [[[CMObjectEncoder encodeObjects:[NSSet setWithObject:point]] allValues] objectAtIndex:0];
        [[[serializedObject objectForKey:@"latitude"] should] equal:theValue(lat)];
        [[[serializedObject objectForKey:@"longitude"] should] equal:theValue(lon)];
        [[[serializedObject objectForKey:@"__type__"] should] equal:@"geopoint"];
    });

    /**
     * Note: This test relies on the proper functioning of <tt>CMObjectEncoder</tt> to
     * generate the original dictionary representation of the object and to test
     * the symmetry of the encode/decode methods.
     */
    it(@"should decode from a dictionary representation into an object correctly", ^{
        CMGeoTestingObject *obj = [[CMGeoTestingObject alloc] init];
        NSDictionary *encodedObj = [CMObjectEncoder encodeObjects:[NSSet setWithObject:obj]];

        CMGeoPoint *point = [[[CMObjectDecoder decodeObjects:encodedObj] objectAtIndex:0] loc];
        [[theValue(point.latitude) should] equal:theValue(47.33)];
        [[theValue(point.longitude) should] equal: theValue(-72.394)];
    });
});

SPEC_END
