//
//  CMJSONEncoder.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMJSONEncoder.h"

@implementation CMJSONEncoder

#pragma mark - Kickoff methods

+ (NSData *)encodeObjects:(id<NSFastEnumeration>)objects {
    return [[[super encodeObjects:objects] yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Translation methods

- (NSData *)jsonData {
    return [[_encodedData yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
