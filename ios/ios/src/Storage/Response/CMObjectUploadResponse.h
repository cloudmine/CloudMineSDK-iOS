//
//  CMObjectUploadResponse.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

@interface CMObjectUploadResponse : CMStoreResponse

@property (strong, atomic) NSDictionary *uploadStatuses;

- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses;
- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithUploadStatuses:(NSDictionary *)uploadStatuses snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
