//
//  NSURL+QueryParameterAdditions.h
//  cloudmine-ios
//
//  Created by Marc Weil on 11/10/11.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryParameterAdditions)

/**
 * Appends a key value to a query string url encoding the value
 * @param key: The key of the query string item
 * @param value: The value of the query string item
 * @returns A new URL
 */
-(NSURL *)URLByAppendingAndEncodingQueryParameter:(NSString *)key andValue:(NSString *)value;

/**
 * Appends a collection of key value pairs to a query string url encoding the values
 * @param queryParameters: the key values to add
 * @return A new URL
 */
-(NSURL *)URLByAppendingAndEncodingQueryParameters:(NSDictionary *)queryParameters;

-(NSURL *)URLByAppendingAndEncodingQuery:(NSString *)query;

@end
