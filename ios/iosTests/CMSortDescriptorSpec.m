//
//  CMUserSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMSortDescriptor.h"

SPEC_BEGIN(CMSortDescriptorSpec)

describe(@"CMSortDescriptor", ^{
    
    context(@"when constructing a new instance", ^{
        it(@"should accept a nil-terminated list of field-direction pairs and allow access to them later", ^{
            CMSortDescriptor *desc = [[CMSortDescriptor alloc] initWithFieldsAndDirections:@"field1", CMSortAscending, @"field2", CMSortDescending, nil];
            [[[desc directionOfField:@"field1"] should] equal:CMSortAscending];
            [[[desc directionOfField:@"field2"] should] equal:CMSortDescending];
        });
        
        it(@"should create an empty descriptor", ^{
            CMSortDescriptor *sort = [CMSortDescriptor emptyDescriptor];
            [[theValue(sort.count) should] beZero];
        });
        
        it(@"should throw an exception if an odd number of fields is given", ^{
            [[theBlock(^{
                CMSortDescriptor *desc = [[CMSortDescriptor alloc] initWithFieldsAndDirections:@"field1", CMSortAscending, @"field2", nil];
                [[theValue(desc.count) should] beGreaterThan:@0];
            }) should] raiseWithName:NSInternalInconsistencyException];
        });
    });

    context(@"after an instance has been constructed", ^{
        __block CMSortDescriptor *desc = nil;

        beforeEach(^{
            desc = [[CMSortDescriptor alloc] initWithFieldsAndDirections:@"field1", CMSortAscending, nil];
        });

        it(@"should store a field and direction pair for later retrieval", ^{
            [[[desc directionOfField:@"field1"] should] equal:CMSortAscending];
            [[theValue([desc count]) should] equal:theValue(1)];
        });
        
        it(@"should sort a field by the default", ^{
            [desc sortByField:@"field1" direction:CMSortDescending];
            [[[desc directionOfField:@"field1"] should] equal:CMSortDescending];
            [desc sortByField:@"field1"];
            [[[desc directionOfField:@"field1"] should] equal:CMSortDefault];
        });
        
        it(@"should sort by the default if no direction is passed", ^{
            [desc sortByField:@"field1" direction:nil];
            [[[desc directionOfField:@"field1"] should] equal:CMSortDefault];
        });

        it(@"should properly remove a field", ^{
            [desc sortByField:@"field2" direction:CMSortAscending];
            [[[desc directionOfField:@"field1"] should] equal:CMSortAscending];
            [[[desc directionOfField:@"field2"] should] equal:CMSortAscending];

            [desc stopSortingByField:@"field2"];
            [[desc directionOfField:@"field2"] shouldBeNil];
            [[desc directionOfField:@"field1"] shouldNotBeNil];

            [[theValue([desc count]) should] equal:theValue(1)];

            [desc stopSortingByField:@"field1"];
            [[desc directionOfField:@"field1"] shouldBeNil];
            [[desc directionOfField:@"field2"] shouldBeNil];

            [[theValue([desc count]) should] equal:theValue(0)];
        });
    });

    context(@"when directions are explicit for all fields", ^{
        it(@"should render itself into URL form properly", ^{
            CMSortDescriptor *desc = [[CMSortDescriptor alloc] initWithFieldsAndDirections:@"field1", CMSortAscending, @"field2", CMSortDescending, nil];
            [desc sortByField:@"field2" direction:CMSortDescending];
            [[[desc stringRepresentation] should] equal:@"sort=field2:desc&sort=field1:asc"];
        });
    });

    context(@"some fields don't have a sort direction made explicit", ^{
        it(@"should render itself into URL form properly", ^{
            CMSortDescriptor *desc = [[CMSortDescriptor alloc] initWithFieldsAndDirections:@"field1", CMSortAscending, nil];
            [desc sortByField:@"field2" direction:CMSortDefault];
            [[[desc stringRepresentation] should] equal:@"sort=field2&sort=field1:asc"];
        });
    });
});

SPEC_END
