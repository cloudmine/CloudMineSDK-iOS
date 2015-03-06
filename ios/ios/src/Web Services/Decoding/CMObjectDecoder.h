//
//  CMObjectDecoder.h
//  cloudmine-ios
//
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@interface CMObjectDecoder : NSCoder {
    NSDictionary *_dictionaryRepresentation;
}

+ (NSArray *)decodeObjects:(NSDictionary *)serializedObjects;

- (instancetype)initWithSerializedObjectRepresentation:(NSDictionary *)representation;

@end
