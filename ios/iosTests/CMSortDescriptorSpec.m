//
//  CMUserSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
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
    });
    
    context(@"after an instance has been constructed", ^{
        __block CMSortDescriptor *desc = nil;
        
        beforeEach(^{
            desc = [[CMSortDescriptor alloc] init];
        });
        
        it(@"should store a field and direction pair for later retrieval", ^{
            [desc sortByField:@"field1" direction:CMSortAscending];
            [[[desc directionOfField:@"field1"] should] equal:CMSortAscending];
            
            [[theValue([desc count]) should] equal:theValue(1)];
        });
        
        it(@"should properly remove a field", ^{
            [desc sortByField:@"field1" direction:CMSortAscending];
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
});

SPEC_END
