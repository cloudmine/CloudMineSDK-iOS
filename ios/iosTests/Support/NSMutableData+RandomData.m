//
//  NSMutableData+RandomData.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "NSMutableData+RandomData.h"

@implementation NSMutableData (RandomData)

+ (id)randomDataWithLength:(NSUInteger)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    [[NSInputStream inputStreamWithFileAtPath:@"/dev/urandom"] read:(uint8_t *)[data mutableBytes] maxLength:length];
    return data;
}

@end
