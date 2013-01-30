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
    return [NSURL URLWithString:$urlencode([self addQuery:queryString])];
}

- (NSURL *)URLByAppendingQueryStringWithoutEncoding:(NSString *)queryString {
    return [NSURL URLWithString:[self addQuery:queryString]];
}

- (NSString *)addQuery:(NSString *)queryString {
    if (![queryString length]) {
        return [self absoluteString];
    }
    return $sprintf(@"%@%@%@", [self absoluteString], [self query] ? @"&" : @"?", queryString);
}

@end
