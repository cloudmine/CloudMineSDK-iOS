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

-(NSURL *)URLByAppendingAndEncodingQueryParameter:(NSString *)key andValue:(NSString *)value;
{
    if (!key || !value || ![key length])
    {
        return [self copy];
    }
    
    NSString *finalURL = [NSString stringWithFormat:@"%@%@%@=%@", [self absoluteString], [self query] ? @"&" : @"?", [CMTools urlEncode:key], [CMTools urlEncode:value]];
    return [NSURL URLWithString:finalURL];
}

-(NSURL *)URLByAppendingAndEncodingQueryParameters:(NSDictionary *)queryParameters
{
    if (!queryParameters)
    {
        return [self copy];
    }
    
    NSURL *finalURL = [self copy];
    
    for (id key in queryParameters)
    {
        finalURL = [finalURL URLByAppendingAndEncodingQueryParameter:key andValue:queryParameters[key]];
    }
    
    return finalURL;
}

-(NSURL *)URLByAppendingAndEncodingQuery:(NSString *)query;
{
    if (![query length]) {
        return [self copy];
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [self absoluteString], [self query] ? @"&" : @"?", [CMTools urlEncodeButLeaveQuery:query]]];
}


@end
