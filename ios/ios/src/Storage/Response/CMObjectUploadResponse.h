//
//  CMObjectUploadResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

/**
 * Response object returned after an object upload request.
 */
@interface CMObjectUploadResponse : CMStoreResponse
/**
 * Dictionary keyed on object id that indicates the result of uploading each new object.
 */
@property (strong, nonatomic, nullable) NSDictionary *uploadStatuses;

- (nonnull instancetype)initWithUploadStatuses:(nullable NSDictionary *)uploadStatuses;
- (nonnull instancetype)initWithUploadStatuses:(nullable NSDictionary *)uploadStatuses snippetResult:(nullable CMSnippetResult *)snippetResult;
- (nonnull instancetype)initWithUploadStatuses:(nullable NSDictionary *)uploadStatuses snippetResult:(nullable CMSnippetResult *)snippetResult responseMetadata:(nullable CMResponseMetadata *)metadata;

@end
