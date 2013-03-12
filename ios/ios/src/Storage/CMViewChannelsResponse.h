//
//  CMGetResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMResponse.h"

typedef enum {
    /** The View Channel Request failed. */
    CMViewChannelsRequestFailed = 0,
    
    /** The View Channel request was a success. Use <tt>channels</tt> to get the channels. */
    CMViewChannelsRequestSucceeded = 1,
    
} CMViewChannelsResult;

/**
 * CMViewChannelsResponse
 *
 * The Response object for viewing what channels a device is in.
 */
@interface CMViewChannelsResponse : CMResponse

/**
 * Returns the result of the Response as an Enum, as defined above.
 * @return The CMViewChannelsResult as defined above.
 */
- (CMViewChannelsResult)result;

/**
 * The NSArray of Channels the device is a part of. This may be an empty array, which means the device was not in any channels.
 * @return The NSArray that the device is in.
 */
- (NSArray *)channels;

@end

/**
 * The callback signature for getting Channels information.
 */
typedef void (^CMViewChannelsRequestCallback)(CMViewChannelsResponse *response);