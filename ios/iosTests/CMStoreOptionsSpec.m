//
//  CMStoreOptionsSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMStoreOptions.h"
#import "CMPagingDescriptor.h"
#import "CMServerFunction.h"

SPEC_BEGIN(CMStoreOptionsSpec)

describe(@"CMStoreOptions", ^{

    __block CMStoreOptions *options = nil;
    __block CMPagingDescriptor *paging = nil;
    __block CMServerFunction *func = nil;

    context(@"given paging options and no server-side function", ^{
        beforeEach(^{
            paging = [[CMPagingDescriptor alloc] initWithLimit:100 skip:10 includeCount:YES];
            options = [[CMStoreOptions alloc] initWithPagingDescriptor:paging];
        });

        it(@"should render them as a query string properly", ^{
            [[[options stringRepresentation] should] equal:[paging stringRepresentation]];
        });
    });

    context(@"given a server-side function and no paging options", ^{
        beforeEach(^{
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo",
                                    @"bye", @"hi", nil];
            func = [[CMServerFunction alloc] initWithFunctionName:@"myFunc"
                                                                    extraParameters:params responseContainsResultOnly:NO performAsynchronously:NO];
            options = [[CMStoreOptions alloc] initWithServerSideFunction:func];
        });

        it(@"should render them as a query string properly", ^{
            [[[options stringRepresentation] should] equal:[func stringRepresentation]];
        });
    });

    context(@"given both a server-side function and paging options", ^{
        beforeEach(^{
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo",
                                    @"bye", @"hi", nil];
            func = [[CMServerFunction alloc] initWithFunctionName:@"myFunc"
                                                  extraParameters:params responseContainsResultOnly:NO performAsynchronously:NO];
            paging = [[CMPagingDescriptor alloc] initWithLimit:100 skip:10 includeCount:YES];
            options = [[CMStoreOptions alloc] initWithPagingDescriptor:paging
                                                 andServerSideFunction:func];
        });

        it(@"should render them as a query string properly", ^{
            NSString *expectedString = [NSString stringWithFormat:@"%@&%@", [paging stringRepresentation], [func stringRepresentation]];
            [[[options stringRepresentation] should] equal:expectedString];
        });

    });
});

SPEC_END
