//
//  CMWebService.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMWebService.h"

@implementation CMWebService
@synthesize networkQueue;

- (id)init {
    if (self = [super init]) {
        self.networkQueue = [ASINetworkQueue queue];
    }
    return self;
}



@end
