//
//  CMSnippetResult.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMSnippetResult.h"

@implementation CMSnippetResult

@synthesize data;

-(id)initWithData:(id)theData {
    if(self = [super init]) {
        data = theData;
    }

    return self;
}

@end
