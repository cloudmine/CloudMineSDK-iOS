//
//  CMTools.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 10/24/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import "CMTools.h"

@implementation CMTools

+ (NSString *)urlEncode:(NSString *)string;
{
    CFStringRef ret = CFURLCreateStringByAddingPercentEscapes(
                                                              kCFAllocatorDefault,
                                                              (CFStringRef)string,
                                                              NULL,
                                                              (CFStringRef)@";/?:@&=+$,",
                                                              kCFStringEncodingUTF8
                                                              );
    return (__bridge NSString *)(ret);
}

+ (NSString *)urlEncodeButLeaveQuery:(NSString *)string;
{
    CFStringRef ret = CFURLCreateStringByAddingPercentEscapes(
                                                              kCFAllocatorDefault,
                                                              (CFStringRef)string,
                                                              NULL,
                                                              (CFStringRef)@";/:@+$,",
                                                              kCFStringEncodingUTF8
                                                              );
    return (__bridge NSString *)(ret);
    
}



@end
