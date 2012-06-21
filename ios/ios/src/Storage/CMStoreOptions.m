//
//  CMStoreOptions.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "SPLowVerbosity.h"

#import "CMStoreOptions.h"
#import "CMPagingDescriptor.h"
#import "CMServerFunction.h"
#import "CMSortDescriptor.h"
#import "CMDistance.h"

@implementation CMStoreOptions
@synthesize pagingDescriptor;
@synthesize serverSideFunction;
@synthesize sortDescriptor;

#define _CMAddIfNotNil(array, obj) if(obj) [array addObject:[obj stringRepresentation]];

@synthesize includeDistance;
@synthesize distanceUnits;

#pragma mark - Initializers

- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor {
    return [self initWithPagingDescriptor:thePagingDescriptor sortDescriptor:nil andServerSideFunction:nil];
}

- (id)initWithSortDescriptor:(CMSortDescriptor *)theSortDescriptor {
    return [self initWithPagingDescriptor:nil sortDescriptor:theSortDescriptor andServerSideFunction:nil];
}

- (id)initWithServerSideFunction:(CMServerFunction *)theServerFunction {
    return [self initWithPagingDescriptor:nil sortDescriptor:nil andServerSideFunction:theServerFunction];
}

- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor sortDescriptor:(CMSortDescriptor *)theSortDescriptor andServerSideFunction:(CMServerFunction *)theServerFunction {
    if (self = [super init]) {
        self.pagingDescriptor = thePagingDescriptor;
        self.serverSideFunction = theServerFunction;
        self.sortDescriptor = theSortDescriptor;
    }
    return self;
}

#pragma mark - Consumable representations

- (NSDictionary *)buildExtraParameters {

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    if(self.includeDistance) {
        [params setObject:@"true" forKey:CMIncludeDistanceKey];
    }
    if(self.distanceUnits) {
        [params setObject:self.distanceUnits forKey:CMDistanceUnitsKey];
    }

    return params;
}

- (NSString *)stringRepresentation {
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:3];
    _CMAddIfNotNil(components, pagingDescriptor);
    _CMAddIfNotNil(components, sortDescriptor);
    _CMAddIfNotNil(components, serverSideFunction);

    return [components componentsJoinedByString:@"&"];
}

@end
