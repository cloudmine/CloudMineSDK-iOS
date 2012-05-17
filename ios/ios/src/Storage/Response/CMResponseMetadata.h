//
//  CMResponseMetadata.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@class CMObject;

@interface CMResponseMetadata : NSObject

@property (strong, atomic) NSDictionary *metadata;

- (id)initWithMetadata:(NSDictionary *)data;
- (NSDictionary *)metadataForObject:(CMObject *)object forKey:(NSString *)key;

@end
