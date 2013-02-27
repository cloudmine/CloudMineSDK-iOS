//
//  CMChannelResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMResponse.h"

typedef enum {
    
    CMDeviceChannelOperationFailed = 0,
    
    CMDeviceAddedToChannel = 1,
    
    CMDeviceRemovedFromChannel = 2
    
} CMDeviceChannelResult;

/**
 * CMChannel Response
 * Encapsulates the response of subscribing or unsubscribing a device to a Channel.
 */
@interface CMChannelResponse : CMResponse

/**
 * The result of the operation.
 * This Response Object is used for both unsubscribing and subscribing - depending on the operation you'll get the
 * correct enum back - either added or removed from the channel.
 * @return The CMDeviceChannelResult of the operation, as defined above.
 */
@property (nonatomic) CMDeviceChannelResult result;

@end

/**
 * The callback signature for subscribing and unsubscribing to channels.
 */
typedef void (^CMWebServiceDeviceChannelCallback)(CMChannelResponse *response);