//
//  CMDeleteResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMDeleteResponse.h"

@implementation CMDeleteResponse

@synthesize success;
@synthesize objectErrors;

- (id)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors {
    return [self initWithSuccess:theSuccess errors:theErrors snippetResult:nil responseMetadata:nil];
}

- (id)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult {
    return [self initWithSuccess:theSuccess errors:theErrors snippetResult:theSnippetResult responseMetadata:nil];
}

- (id)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult responseMetadata:(CMResponseMetadata *)theMetadata {
    if (self = [super initWithMetadata:theMetadata snippetResult:theSnippetResult]) {
        self.success = theSuccess;
        self.objectErrors = theErrors;
    }
    return self;
}

@end
