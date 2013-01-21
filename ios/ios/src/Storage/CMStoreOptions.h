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
 * @see https://cloudmine.me/dashboard/apps
 * @see https://cloudmine.me/docs/ios/reference#code
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
- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor;
- (id)initWithServerSideFunction:(CMServerFunction *)theServerFunction;
- (id)initWithSortDescriptor:(CMSortDescriptor *)theSortDescriptor;
- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor sortDescriptor:(CMSortDescriptor *)theSortDescriptor andServerSideFunction:(CMServerFunction *)theServerFunction;

/**
 * Creates a key => value dictionary of extra parameters to be added to the query URL.
 */
- (NSDictionary *)buildExtraParameters;

/**
 * Converts all the set properties into a query string format that can be appended to a URL.
 */
- (NSString *)stringRepresentation;

@end
