//
//  CMStoreOptions.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@class CMPagingDescriptor;
@class CMServerFunction;
@class CMSortDescriptor;

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
 * Options for specifying one or more fields to sort the resulting objects by.
 *
 * @see CMSortDescriptor
 */
@property (nonatomic, strong) CMSortDescriptor *sortDescriptor;

/**
 * Options for specifying a function you've defined on your CloudMine dashboard to be run as a post-processing step
 * server-side before the objects are sent back to this store.
 *
 * @see CMServerFunction
 * @see https://compass.cloudmine.io/apps
 * @see https://cloudmine.io/docs/ios/reference#code
 */
@property (nonatomic, strong) CMServerFunction *serverSideFunction;

/**
 * Whether or not to include shared objects in the results.
 */
@property (nonatomic) BOOL shared;

/**
 * If this is set to YES, only shared objects will be returned in the results.
 */
@property (nonatomic) BOOL sharedOnly;

@property (nonatomic) BOOL includeDistance;
@property (nonatomic, strong) NSString *distanceUnits;

/**
 *
 */
- (instancetype)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor;
- (instancetype)initWithServerSideFunction:(CMServerFunction *)theServerFunction;
- (instancetype)initWithSortDescriptor:(CMSortDescriptor *)theSortDescriptor;
- (instancetype)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor sortDescriptor:(CMSortDescriptor *)theSortDescriptor andServerSideFunction:(CMServerFunction *)theServerFunction;

/**
 * Creates a key => value dictionary of extra parameters to be added to the query URL.
 */
- (NSDictionary *)buildExtraParameters;

/**
 * Converts all the set properties into a query string format that can be appended to a URL.
 */
- (NSString *)stringRepresentation;

@end
