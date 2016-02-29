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
@property (strong, nonatomic) NSDictionary *uploadStatuses;

- (instancetype)initWithUploadStatuses:(NSDictionary *)uploadStatuses;
- (instancetype)initWithUploadStatuses:(NSDictionary *)uploadStatuses snippetResult:(CMSnippetResult *)snippetResult;
- (instancetype)initWithUploadStatuses:(NSDictionary *)uploadStatuses snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
