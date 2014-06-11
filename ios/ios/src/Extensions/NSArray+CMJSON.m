//
//  NSArray+CMJSON.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 10/24/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "NSArray+CMJSON.h"
#import "CMTools.h"

@implementation NSArray (CMJSON)

- (NSString *)jsonString;
{
    return [[NSString alloc] initWithData:[self jsonData] encoding:NSUTF8StringEncoding];
}

- (NSData *)jsonData;
{
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
}

@end
