//
//  CMDeleteResponse.m
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMDeleteResponse.h"

@implementation CMDeleteResponse

@synthesize success;
@synthesize errors;

- (id)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors {
    return [self initWithSuccess:theSuccess errors:theErrors snippetResult:nil responseMetadata:nil];
}

- (id)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult {
    return [self initWithSuccess:theSuccess errors:theErrors snippetResult:theSnippetResult responseMetadata:nil];
}

- (id)initWithSuccess:(NSDictionary *)theSuccess errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult responseMetadata:(CMResponseMetadata *)theMetadata {
    if (self = [super initWithMetadata:theMetadata snippetResult:theSnippetResult]) {
        self.success = theSuccess;
        self.errors = theErrors;
    }
    return self;
}

@end
