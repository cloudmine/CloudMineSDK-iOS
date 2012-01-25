//
//  CMStoreOptions.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStoreOptions.h"

#import "CMPagingDescriptor.h"
#import "CMServerFunction.h"

@implementation CMStoreOptions
@synthesize pagingDescriptor;
@synthesize serverSideFunction;

#pragma mark - Initializers

- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor {
    return [self initWithPagingDescriptor:thePagingDescriptor andServerSideFunction:nil];
}

- (id)initWithServerSideFunction:(CMServerFunction *)theServerFunction {
    return [self initWithPagingDescriptor:nil andServerSideFunction:theServerFunction];
}

- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor andServerSideFunction:(CMServerFunction *)theServerFunction {
    if (self = [super init]) {
        self.pagingDescriptor = thePagingDescriptor;
        self.serverSideFunction = theServerFunction;
    }
    return self;
}

#pragma mark - Consumable representations

- (NSString *)stringRepresentation {
    if (pagingDescriptor && serverSideFunction) {
        return [NSString stringWithFormat:@"%@&%@", [pagingDescriptor stringRepresentation], [serverSideFunction stringRepresentation]];
    } else if (pagingDescriptor) {
        return [pagingDescriptor stringRepresentation];
    } else {
        return [serverSideFunction stringRepresentation];
    }
}

@end
