//
//  CMObjectUploadResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

@interface CMObjectUploadResponse : CMStoreResponse

@property (strong, atomic) NSDictionary *uploadStatuses;

- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses;
- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
