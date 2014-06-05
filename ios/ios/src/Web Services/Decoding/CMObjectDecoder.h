//
//  CMObjectDecoder.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@interface CMObjectDecoder : NSCoder {
    NSDictionary *_dictionaryRepresentation;
}

+ (NSArray *)decodeObjects:(NSDictionary *)serializedObjects;

- (id)initWithSerializedObjectRepresentation:(NSDictionary *)representation;

@end
