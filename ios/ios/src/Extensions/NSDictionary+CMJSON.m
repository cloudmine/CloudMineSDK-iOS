//
//  NSDictionary+CMJSON.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 10/24/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "NSDictionary+CMJSON.h"
#import "CMTools.h"

@implementation NSDictionary (CMJSON)

- (NSString *)jsonString;
{
    return [[NSString alloc] initWithData:[self jsonData] encoding:NSUTF8StringEncoding];
}

- (NSData *)jsonData;
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error) {
        DLog(@"Error Serializing %@. Error: %@", self, error);
    }
    return data;
}

@end
