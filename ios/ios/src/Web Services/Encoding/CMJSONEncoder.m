//
//  CMJSONEncoder.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMJSONEncoder.h"

@implementation CMJSONEncoder

#pragma mark - Kickoff methods

+ (NSString *)encodeObjects:(id<NSFastEnumeration>)objects {
    return [[super encodeObjects:objects] yajl_JSONString];
}

#pragma mark - Translation methods

- (NSString *)encodedRepresentation {
    return [_encodedData yajl_JSONString];
}

@end
