//
//  CMGetResponse.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 2/26/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMResponse.h"

typedef enum {
    
    CMGetRequestFailed = 0,
    
    CMGetRequestSucceeded = 1,
    
} CMGetRequestResult;

@interface CMGetResponse : CMResponse

- (CMGetRequestResult)result;

@end

typedef void (^CMGetRequestCallback)(CMGetResponse *response);