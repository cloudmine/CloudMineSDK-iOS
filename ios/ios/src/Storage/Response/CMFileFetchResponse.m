//
//  CMFileFetchResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMFileFetchResponse.h"
#import "CMFile.h"

@implementation CMFileFetchResponse

@synthesize file;

- (id)initWithFile:(CMFile *)theFile {
    if(self = [super init]) {
        self.file = theFile;
    }

    return self;
}

@end
