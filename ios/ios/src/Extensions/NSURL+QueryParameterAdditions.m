//
//  NSURL+QueryParameterAdditions.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "NSURL+QueryParameterAdditions.h"

@implementation NSURL (QueryParameterAdditions)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    return [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
