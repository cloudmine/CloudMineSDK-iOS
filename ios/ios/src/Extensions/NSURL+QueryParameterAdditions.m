//
//  NSURL+QueryParameterAdditions.m
//  cloudmine-ios
//
//  Created by Marc Weil on 11/10/11.
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//

#import "NSURL+QueryParameterAdditions.h"

@implementation NSURL (QueryParameterAdditions)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    NSString *escapedURLString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                         (__bridge CFStringRef)URLString, 
                                                                         NULL, 
                                                                         NULL, 
                                                                         kCFStringEncodingUTF8);
    return [NSURL URLWithString:escapedURLString];
}

@end
