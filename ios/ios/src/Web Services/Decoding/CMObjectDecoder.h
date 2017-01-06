//
//  CMObjectDecoder.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@interface CMObjectDecoder : NSCoder {
    NSDictionary *_dictionaryRepresentation;
}

+ (nonnull NSArray *)decodeObjects:(nullable NSDictionary *)serializedObjects;

- (nonnull instancetype)initWithSerializedObjectRepresentation:(nullable NSDictionary *)representation;

@end
