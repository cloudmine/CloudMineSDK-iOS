//
//  CMObjectUploadResponse.m
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMObjectUploadResponse.h"

@implementation CMObjectUploadResponse

@synthesize uploadStatuses;

- (id)initWithUploadStatuses:(NSDictionary *)theUploadStatuses {
    return [self initWithUploadStatuses:theUploadStatuses snippetResult:nil responseMetadata:nil];
}

- (id)initWithUploadStatuses:(NSDictionary *)theUploadStatuses snippetResult:(CMSnippetResult *)theSnippetResult {
    return [self initWithUploadStatuses:theUploadStatuses snippetResult:theSnippetResult responseMetadata:nil];
}

- (id)initWithUploadStatuses:(NSDictionary *)theUploadStatuses snippetResult:(CMSnippetResult *)theSnippetResult responseMetadata:(CMResponseMetadata *)theMetadata {
    if (self = [super initWithMetadata:theMetadata snippetResult:theSnippetResult]) {
        self.uploadStatuses = theUploadStatuses;
    }
    return self;
}

@end
