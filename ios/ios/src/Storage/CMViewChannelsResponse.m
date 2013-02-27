//
//  CMGetResponse.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 2/26/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMGetResponse.h"

@implementation CMGetResponse

- (CMGetRequestResult)result {
    return 200 <= self.httpResponseCode &&  self.httpResponseCode < 300 ? CMGetRequestSucceeded : CMGetRequestFailed;
}

@end
