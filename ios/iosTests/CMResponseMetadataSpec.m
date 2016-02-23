
//
//  CMResponseMetadata.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMResponseMetadata.h"
#import "CMDistance.h"
#import "CMObject.h"

SPEC_BEGIN(CMResponseMetadataSpec)

describe(@"CMResponseMetadata", ^{
    
    it(@"should properly create the distance", ^{
        
        CMObject *object = [[CMObject alloc] initWithObjectId:@"testID"];
        
        CMResponseMetadata *meta = [[CMResponseMetadata alloc] initWithMetadata:@{@"testID": @{@"geo": @{@"distance": @33, @"units" : CMDistanceUnitsMi}}}];
        CMDistance *distance = [meta distanceFromObject:object];
        
        [[distance shouldNot] beNil];
        [[theValue(distance.distance) should] equal:@33];
        [[distance.units should] equal:@"mi"];
    });
    
    it(@"should return nil if there is no meta data", ^{
        CMObject *object = [[CMObject alloc] initWithObjectId:@"wrongID"];

        CMResponseMetadata *meta = [[CMResponseMetadata alloc] initWithMetadata:@{@"testID": @{@"geo": @{@"distance": @33, @"units" : CMDistanceUnitsMi}}}];
        CMDistance *distance = [meta distanceFromObject:object];
        [[distance should] beNil];
    });
    
});

SPEC_END

