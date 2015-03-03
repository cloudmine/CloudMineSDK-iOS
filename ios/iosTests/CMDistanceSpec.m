//
//  CMDistanceSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMDistance.h"

SPEC_BEGIN(CMDistanceSpec)

describe(@"CMDistance", ^{

    it(@"should properly be created", ^{
        CMDistance *distance = [[CMDistance alloc] initWithDistance:10 andUnits:CMDistanceUnitsMi];
        [[@(distance.distance) should] equal:@10];
        [[distance.units should] equal:@"mi"];
    });
    
});

SPEC_END
