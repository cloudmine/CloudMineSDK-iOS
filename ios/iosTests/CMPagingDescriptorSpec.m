//
//  CMPagingDescriptorSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMPagingDescriptor.h"

SPEC_BEGIN(CMPagingDescriptorSpec)

describe(@"CMPagingDescriptor", ^{

    __block CMPagingDescriptor *descriptor = nil;

    context(@"given custom paging options", ^{
        beforeEach(^{
            descriptor = [[CMPagingDescriptor alloc] initWithLimit:100 skip:10 includeCount:YES];
        });

        it(@"should render them as a query string properly", ^{
            NSString *expectedString = @"limit=100&skip=10&count=true";
            [[[descriptor stringRepresentation] should] equal:expectedString];
        });
    });

    context(@"given default paging options", ^{
        beforeEach(^{
            descriptor = [CMPagingDescriptor defaultPagingDescriptor];
        });

        it(@"should render them as a query string properly", ^{
            NSString *expectedString = @"limit=50&skip=0&count=false";
            [[[descriptor stringRepresentation] should] equal:expectedString];
        });
    });
});

SPEC_END
