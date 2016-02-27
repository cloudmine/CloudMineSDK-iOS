//
//  CMPagingDescriptorSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
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
        
        it(@"should be created with just a limit", ^{
            CMPagingDescriptor *newDescriptor = [[CMPagingDescriptor alloc] initWithLimit:90];
            [[theValue(newDescriptor.limit) should] equal:@90];
            [[theValue(newDescriptor.skip) should] equal:@0];
            [[theValue(newDescriptor.includeCount) should] beFalse];
        });
        
        it(@"should be created with a limit and a skip", ^{
            CMPagingDescriptor *newDescriptor = [[CMPagingDescriptor alloc] initWithLimit:90 skip:50];
            [[theValue(newDescriptor.limit) should] equal:@90];
            [[theValue(newDescriptor.skip) should] equal:@50];
            [[theValue(newDescriptor.includeCount) should] beFalse];
        });
        
        it(@"should correctly create the dictionary representation", ^{
            NSDictionary *data = [descriptor dictionaryRepresentation];
            [[data[CMPagingDescriptorLimitKey] should] equal:@100];
            [[data[CMPagingDescriptorSkipKey] should] equal:@10];
            [[data[CMPagingDescriptorCountKey] should] equal:@YES];
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
