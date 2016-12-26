//
//  CMTools.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 10/24/13.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "CMTools.h"

@implementation CMTools

+ (NSString *)urlEncode:(NSString *)string;
{
    NSString* ret = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                              kCFAllocatorDefault,
                                                              (CFStringRef)string,
                                                              NULL,
                                                              (CFStringRef)@";/?:@&=+$,",
                                                              kCFStringEncodingUTF8
                                                              );
    return ret;
}

+ (NSString *)urlEncodeButLeaveQuery:(NSString *)string;
{
    NSString* ret = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                              kCFAllocatorDefault,
                                                              (CFStringRef)string,
                                                              NULL,
                                                              (CFStringRef)@";/:@+$,",
                                                              kCFStringEncodingUTF8
                                                              );
    return ret;
}



@end
