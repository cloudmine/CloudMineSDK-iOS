//
//  CMFileFetchResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMFileFetchResponse.h"
#import "CMFile.h"

@implementation CMFileFetchResponse

@synthesize file;

- (instancetype)initWithFile:(CMFile *)theFile {
    if(self = [super init]) {
        self.file = theFile;
    }

    return self;
}

@end
