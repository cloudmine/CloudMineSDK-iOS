//
//  NSURL+QueryParameterAdditions.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "SPLowVerbosity.h"
#import "NSURL+QueryParameterAdditions.h"

@implementation NSURL (QueryParameterAdditions)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }

    NSString *URLString = $sprintf(@"%@%@%@", [self absoluteString], [self query] ? @"&" : @"?", queryString);
    return [NSURL URLWithString:$urlencode(URLString)];
}

@end
