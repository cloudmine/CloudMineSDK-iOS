//
//  CMResponseMetadata.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMResponseMetadata.h"
#import "CMObject.h"

@implementation CMResponseMetadata

@synthesize metadata;

- (id)initWithMetadata:(NSDictionary *)data {
    if(self = [super init]) {
        self.metadata = data;
    }
    
    return self;
}

- (NSDictionary *)metadataForObject:(CMObject *)object forKey:(NSString *)key {
    if(metadata) {
        NSDictionary *metaForObject = [metadata objectForKey:object.objectId];
        if(metaForObject) {
            return [metaForObject objectForKey:key];
        }
    }
    
    return nil;
}

@end
