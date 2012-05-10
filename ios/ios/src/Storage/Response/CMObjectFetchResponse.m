//
//  CMObjectFetchResponse.m
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMObjectFetchResponse.h"

@implementation CMObjectFetchResponse

@synthesize objects;
@synthesize errors;

- (id)initWithObjects:(NSArray *)theObjects errors:(NSDictionary *)theErrors {
    return [self initWithObjects:theObjects errors:theErrors snippetResult:nil responseMetadata:nil];
}

- (id)initWithObjects:(NSArray *)theObjects errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult {
    return [self initWithObjects:theObjects errors:theErrors snippetResult:theSnippetResult responseMetadata:nil];
}

- (id)initWithObjects:(NSArray *)theObjects errors:(NSDictionary *)theErrors snippetResult:(CMSnippetResult *)theSnippetResult responseMetadata:(CMResponseMetadata *)theMetadata {
    if (self = [super initWithMetadata:theMetadata snippetResult:theSnippetResult]) {
        self.objects = theObjects;
        self.errors = theErrors;
    }
    return self;
}

@end
