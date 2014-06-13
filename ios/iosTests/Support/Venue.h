//
//  Venue.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "CloudMine.h"

@interface Venue : CMObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) NSUInteger zip;
@property (nonatomic, strong) CMGeoPoint *location;
@property (nonatomic, strong) CMFile *categoryIcon;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end