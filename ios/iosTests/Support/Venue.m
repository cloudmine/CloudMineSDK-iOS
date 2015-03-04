//
//  Venue.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//

#import "Venue.h"

@implementation Venue

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    if (self = [super init]) {
        _name = [dictionary objectForKey:@"name"];
        _address = [[dictionary objectForKey:@"location"] objectForKey:@"address"];
        _city = [[dictionary objectForKey:@"location"] objectForKey:@"city"];
        _state = [[dictionary objectForKey:@"location"] objectForKey:@"state"];
        _zip = [[[dictionary objectForKey:@"location"] objectForKey:@"postalCode"] intValue];
        _location = [[CMGeoPoint alloc] initWithLatitude:[[[dictionary objectForKey:@"location"] objectForKey:@"lat"] doubleValue]
                                           andLongitude:[[[dictionary objectForKey:@"location"] objectForKey:@"lng"] doubleValue]];
        _categoryIcon = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _address = [aDecoder decodeObjectForKey:@"address"];
        _city = [aDecoder decodeObjectForKey:@"city"];
        _state = [aDecoder decodeObjectForKey:@"state"];
        _zip = [aDecoder decodeIntForKey:@"zip"];
        _location = [aDecoder decodeObjectForKey:@"location"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_address forKey:@"address"];
    [aCoder encodeObject:_city forKey:@"city"];
    [aCoder encodeObject:_state forKey:@"state"];
    [aCoder encodeInteger:_zip forKey:@"zip"];
    [aCoder encodeObject:_location forKey:@"location"];
}

+ (NSString *)className {
    return @"venue";
}

- (BOOL)isEqual:(Venue *)object {
    return ([super isEqual:object] && (((_name == nil) && (object.name == nil)) || [_name isEqualToString:[object name]]) &&
            (((_address == nil) && (object.address == nil)) || [_address isEqualToString:[object address]]) &&
            (((_city == nil) && (object.city == nil)) || [_city isEqualToString:[object city]]) &&
            (((_state == nil) && (object.state == nil)) || [_state isEqualToString:[object state]]) &&
            _zip == [object zip] && (((_location == nil) && (object.location == nil)) || [_location isEqual:[object location]]));
}

@end