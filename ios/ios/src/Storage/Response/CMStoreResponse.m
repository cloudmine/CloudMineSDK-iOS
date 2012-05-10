//
//  CMStoreResponse.m
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMStoreResponse.h"

@implementation CMStoreResponse

@synthesize snippetResult;
@synthesize metadata;

- (id)initWithMetadata:(CMResponseMetadata *)theMetadata snippetResult:(CMSnippetResult *)theSnippetResult {
    if (self = [super init]) {
        self.snippetResult = theSnippetResult;
        self.metadata = theMetadata;
    }
    return self;
}

@end
