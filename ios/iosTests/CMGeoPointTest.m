//
//  CMGeoPointSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMGeoPoint.h"
#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"
#import "CMAPICredentials.h"
#import <CoreLocation/CoreLocation.h>

@interface CMGeoTestingObject : CMObject
@property (strong) NSString *name;
@property (strong) CMGeoPoint *loc;
@end

@implementation CMGeoTestingObject
@synthesize name,loc;
- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"foo";
        self.loc = [[CMGeoPoint alloc] initWithLatitude:47.33 andLongitude:-72.394];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
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
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setApiKey:@"appSecret"];
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"appIdentifier"];
    });

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
    
    it(@"should initialize properly from a CLLocation", ^{
        CLLocation *location = [[CLLocation alloc] initWithLatitude:10.0 longitude:11.0];
        CMGeoPoint *point = [[CMGeoPoint alloc] initWithCLLocation:location];
        [[theValue(point.latitude) should] equal:@10];
        [[theValue(point.longitude) should] equal:@11];
    });
    
    it(@"should know when two points are equal", ^{
        CMGeoPoint *point1 = [[CMGeoPoint alloc] initWithLatitude:12.5 andLongitude:16.5];
        [[point1 shouldNot] equal:@"String"];
        
        CMGeoPoint *point2 = [[CMGeoPoint alloc] initWithLatitude:22.55 andLongitude:35.64];
        [[point1 shouldNot] equal:point2];
        
        CMGeoPoint *point3 = [[CMGeoPoint alloc] initWithLatitude:12.5 andLongitude:16.5];
        [[point1 should] equal:point3];
        
    });
});

SPEC_END
