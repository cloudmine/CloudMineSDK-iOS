//
//  CMGetResponse.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 2/26/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMResponse.h"

typedef enum {
    
    CMViewChannelsRequestFailed = 0,
    
    CMViewChannelsRequestSucceeded = 1,
    
} CMViewChannelsResult;

@interface CMViewChannelsResponse : CMResponse

- (CMViewChannelsResult)result;
- (NSArray *)channels;

@end

typedef void (^CMViewChannelsRequestCallback)(CMViewChannelsResponse *response);