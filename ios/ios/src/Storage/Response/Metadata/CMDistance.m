//
//  CMDistance.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMDistance.h"

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
