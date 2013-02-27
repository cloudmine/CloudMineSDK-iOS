//
//  CMChannelResponse.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 2/26/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMResponse.h"

typedef enum {
    
    CMDeviceChannelOperationFailed = 0,
    
    CMDeviceAddedToChannel = 1,
    
    CMDeviceRemovedFromChannel = 2
    
} CMDeviceChannelResult;


@interface CMChannelResponse : CMResponse

@property (nonatomic) CMDeviceChannelResult result;

@end


typedef void (^CMWebServiceDeviceChannelCallback)(CMChannelResponse *response);