//
//  CMWebService.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

/**
 * Base class for all classes concerned with the communication between the client device and the CloudMine 
 * web services.
 */
@interface CMWebService : NSObject {
    NSString *_apiKey;
    NSString *_appKey;
}

/**
 * The message queue used to send messages to the CloudMine web services.
 *
 * One of these exists for each instance of <tt>CMWebService</tt>, allowing you to parallelize
 * network communication.
 */
@property (strong) ASINetworkQueue *networkQueue;

- (id)init;
- (id)initWithAPIKey:(NSString *)apiKey appKey:(NSString *)appKey;

@end
