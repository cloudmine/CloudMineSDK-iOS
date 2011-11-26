//
//  CMJSONEncoder.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectEncoder.h"

@interface CMJSONEncoder : CMObjectEncoder

@property (atomic, readonly) NSData *jsonData;

+ (NSData *)encodeObjects:(id<NSFastEnumeration>)objects;

@end
