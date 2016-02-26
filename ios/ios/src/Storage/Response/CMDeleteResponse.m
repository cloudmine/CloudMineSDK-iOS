//
//  CMDeleteResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMDeleteResponse.h"

@implementation CMDeleteResponse

@synthesize success;
@synthesize objectErrors;

- (instancetype)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors {
    return [self initWithSuccess:theSuccess errors:theErrors snippetResult:nil responseMetadata:nil];
}

- (instancetype)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult {
    return [self initWithSuccess:theSuccess errors:theErrors snippetResult:theSnippetResult responseMetadata:nil];
}

- (instancetype)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult responseMetadata:(CMResponseMetadata *)theMetadata {
    if (self = [super initWithMetadata:theMetadata snippetResult:theSnippetResult]) {
        self.success = theSuccess;
        self.objectErrors = theErrors;
    }
    return self;
}

@end
