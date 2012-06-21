//
//  CMObjectFetchResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectFetchResponse.h"

@implementation CMObjectFetchResponse

@synthesize objects;
@synthesize objectErrors;
@synthesize count;

- (id)initWithObjects:(NSArray *)theObjects errors:(NSDictionary *)theErrors {
    return [self initWithObjects:theObjects errors:theErrors snippetResult:nil responseMetadata:nil];
}

- (id)initWithObjects:(NSArray *)theObjects errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult {
    return [self initWithObjects:theObjects errors:theErrors snippetResult:theSnippetResult responseMetadata:nil];
}

- (id)initWithObjects:(NSArray *)theObjects errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult responseMetadata:(CMResponseMetadata *)theMetadata {
    if (self = [super initWithMetadata:theMetadata snippetResult:theSnippetResult]) {
        self.objects = theObjects;
        self.objectErrors = theErrors;
    }
    return self;
}

@end
