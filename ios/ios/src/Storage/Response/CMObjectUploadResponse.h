//
//  CMObjectUploadResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
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

- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses;
- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
