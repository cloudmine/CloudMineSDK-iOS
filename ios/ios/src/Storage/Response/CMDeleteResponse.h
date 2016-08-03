//
//  CMDeleteResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

/**
 * Response object returned after a delete request.
 */
@interface CMDeleteResponse : CMStoreResponse

/**
 * Dictionary keyed on object id, indicating that the deletion was successful.
 */
@property (strong, nonatomic, nullable) NSDictionary *success;
/**
 * Dictionary keyed on object id, indicting which objects had errors.
 */
@property (strong, nonatomic, nullable) NSDictionary *objectErrors;

- (nonnull instancetype)initWithSuccess:(nullable NSDictionary *)success errors:(nullable NSDictionary *)errors;
- (nonnull instancetype)initWithSuccess:(nullable NSDictionary *)success errors:(nullable NSDictionary *)errors snippetResult:(nullable CMSnippetResult *)snippetResult;
- (nonnull instancetype)initWithSuccess:(nullable NSDictionary *)success errors:(nullable NSDictionary *)errors snippetResult:(nullable CMSnippetResult *)snippetResult responseMetadata:(nullable CMResponseMetadata *)metadata;

@end
