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

@interface CMWebService : NSObject

@property (strong) ASINetworkQueue *networkQueue;

@end
