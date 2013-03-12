//
//  CMGetResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMViewChannelsResponse.h"

@implementation CMViewChannelsResponse

- (CMViewChannelsResult)result {
    return 200 <= self.httpResponseCode &&  self.httpResponseCode < 300 ? CMViewChannelsRequestSucceeded : CMViewChannelsRequestFailed;
}

- (NSArray *)channels {
    if ([self.body isKindOfClass:[NSArray class]]) {
        return (NSArray *)self.body;
    }
    return nil;
}

@end
