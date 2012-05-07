//
//  CMStoreOptions.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@class CMPagingDescriptor;
@class CMServerFunction;

/**
 * This object describes additional configuration you can pass to a <tt>CMStore</tt> to customize how it
 * runs. See each property in this class for information on what is customizable.
 */
@interface CMStoreOptions : NSObject

/**
 * Options for specifying limits, offsets, and other paging-related information.
 *
 * @see CMPagingDescriptor
 */
@property (nonatomic, strong) CMPagingDescriptor *pagingDescriptor;

/**
 * Options for specifying a function you've defined on your CloudMine dashboard to be run as a post-processing step
 * server-side before the objects are sent back to this store.
 *
 * @see CMServerFunction
 * @see https://cloudmine.me/dashboard/apps
 * @see https://cloudmine.me/developer_zone#code/overview
 */
@property (nonatomic, strong) CMServerFunction *serverSideFunction;

/**
 * Extra parameters that should be passed into the query.
 */
@property (nonatomic, strong) BOOL includeDistance;

/**
 * 

- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor;
- (id)initWithServerSideFunction:(CMServerFunction *)theServerFunction;
- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor andServerSideFunction:(CMServerFunction *)theServerFunction;
- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor andServerSideFunction:(CMServerFunction *)theServerFunction andQueryParameters:(NSDictionary *)queryParams;
- (void)addQueryParameterWithKey:(NSString*)key andValue:(id)value;

/**
 * Converts all the set properties into a query string format that can be appended to a URL.
 */
- (NSString *)stringRepresentation;

@end
