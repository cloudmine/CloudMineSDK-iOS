//
//  CMResponseMetadata.m
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
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
