//
//  NSURL+QueryParameterAdditions.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "NSURL+QueryParameterAdditions.h"
#import "CMTools.h"

@implementation NSURL (QueryParameterAdditions)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    return [NSURL URLWithString:[CMTools urlEncode:[self addQuery:queryString]]];
}

- (NSURL *)URLByAppendingAndEncodingQueryString:(NSString *)queryString {
    return [NSURL URLWithString:[self addQuery:[CMTools urlEncode:queryString]]];
}

- (NSString *)addQuery:(NSString *)queryString {
    if (![queryString length]) {
        return [self absoluteString];
    }
    
    return [NSString stringWithFormat:@"%@%@%@", [self absoluteString], [self query] ? @"&" : @"?", queryString];
}

@end
