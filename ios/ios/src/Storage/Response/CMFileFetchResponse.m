//
//  CMFileFetchResponse.m
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMFileFetchResponse.h"

@implementation CMFileFetchResponse

@synthesize file;

- (id)initWithFile:(CMFile *)theFile {
    if(self = [super init]) {
        self.file = theFile;
    }
    
    return self;
}

@end
