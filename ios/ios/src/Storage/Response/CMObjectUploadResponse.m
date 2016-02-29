//
//  CMObjectUploadResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectUploadResponse.h"

@implementation CMObjectUploadResponse

@synthesize uploadStatuses;

- (instancetype)initWithUploadStatuses:(NSDictionary *)theUploadStatuses {
    return [self initWithUploadStatuses:theUploadStatuses snippetResult:nil responseMetadata:nil];
}

- (instancetype)initWithUploadStatuses:(NSDictionary *)theUploadStatuses snippetResult:(CMSnippetResult *)theSnippetResult {
    return [self initWithUploadStatuses:theUploadStatuses snippetResult:theSnippetResult responseMetadata:nil];
}

- (instancetype)initWithUploadStatuses:(NSDictionary *)theUploadStatuses snippetResult:(CMSnippetResult *)theSnippetResult responseMetadata:(CMResponseMetadata *)theMetadata {
    if (self = [super initWithMetadata:theMetadata snippetResult:theSnippetResult]) {
        self.uploadStatuses = theUploadStatuses;
    }
    return self;
}

@end
