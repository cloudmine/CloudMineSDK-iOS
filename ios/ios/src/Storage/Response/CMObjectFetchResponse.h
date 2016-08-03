//
//  CMObjectFetchResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

/**
 * Response object returned after an object fetch request.
 */
@interface CMObjectFetchResponse : CMStoreResponse

/**
 * The objects returned by the CloudMine API. These will all inherit from CMSerializable.
 */
@property (strong, nonatomic, nullable) NSArray *objects;
/**
 * Errors returned from the API.
 */
@property (strong, nonatomic, nullable) NSDictionary *objectErrors;

/**
 * Count of objects returned.
 */
@property (nonatomic) NSInteger count;

- (nonnull instancetype)initWithObjects:(nullable NSArray *)objects errors:(nullable NSDictionary *)errors;
- (nonnull instancetype)initWithObjects:(nullable NSArray *)objects errors:(nullable NSDictionary *)errors snippetResult:(nullable CMSnippetResult *)snippetResult;
- (nonnull instancetype)initWithObjects:(nullable NSArray *)objects errors:(nullable NSDictionary *)errors snippetResult:(nullable CMSnippetResult *)snippetResult responseMetadata:(nullable CMResponseMetadata *)metadata;

@end
