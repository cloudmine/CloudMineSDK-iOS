//
//  CMResponseMetadata.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMObject;

@interface CMResponseMetadata : NSObject

@property (strong, atomic) NSDictionary *metadata;

- (id)initWithMetadata:(NSDictionary *)data;
- (NSDictionary *)metadataForObject:(CMObject *)object forKey:(NSString *)key;

@end
