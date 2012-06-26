//
//  CMStoreResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStoreResponse.h"

@implementation CMStoreResponse

@synthesize snippetResult;
@synthesize metadata;
@synthesize error;

- (id)initWithMetadata:(CMResponseMetadata *)theMetadata snippetResult:(CMSnippetResult *)theSnippetResult {
    if (self = [super init]) {
        self.snippetResult = theSnippetResult;
        self.metadata = theMetadata;
    }
    return self;
}

- (id)initWithError:(NSError *)theError {
    if ((self = [super init])) {
        self.error = theError;
    }
    return self;
}

@end
