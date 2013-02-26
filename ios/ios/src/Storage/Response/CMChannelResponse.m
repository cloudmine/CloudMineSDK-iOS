//
//  CMChannelResponse.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 2/26/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMChannelResponse.h"

@interface CMChannelResponse()
@property (nonatomic) BOOL subscribe;
@end

@implementation CMChannelResponse

@synthesize result = _result, subscribe;

- (CMDeviceChannelResult)result {
    return self.httpResponseCode == 200 ? (self.subscribe ? CMDeviceAddedToChannel : CMDeviceRemovedFromChannel) : CMDeviceChannelOperationFailed;
}

@end
