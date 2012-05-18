//
//  CMFileUploadResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMFileUploadResponse.h"

@implementation CMFileUploadResponse

@synthesize result;
@synthesize key;

- (id)initWithResult:(CMFileUploadResult)theResult key:(NSString *)theKey {
    return [self initWithResult:theResult key:theKey snippetResult:nil responseMetadata:nil];
}

- (id)initWithResult:(CMFileUploadResult)theResult key:(NSString *)theKey snippetResult:(CMSnippetResult *)theSnippetResult {
    return [self initWithResult:theResult key:theKey snippetResult:theSnippetResult responseMetadata:nil];
}

- (id)initWithResult:(CMFileUploadResult)theResult key:(NSString *)theKey snippetResult:(CMSnippetResult *)theSnippetResult responseMetadata:(CMResponseMetadata *)theMetadata {
    if (self = [super initWithMetadata:theMetadata snippetResult:theSnippetResult]) {
        self.result = theResult;
        self.key = theKey;
    }
    return self;
}

@end
