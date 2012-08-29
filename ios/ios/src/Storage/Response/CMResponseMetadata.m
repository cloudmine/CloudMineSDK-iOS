//
//  CMResponseMetadata.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMResponseMetadata.h"
#import "CMObject.h"
#import "CMDistance.h"

NSString * const CMMetadataTypeGeo = @"geo";

@implementation CMResponseMetadata {
    NSDictionary *metadata;
}

- (id)initWithMetadata:(NSDictionary *)data {
    if(self = [super init]) {
        metadata = data;
    }

    return self;
}

- (id)metadataForObject:(CMObject *)object ofType:(NSString *)type {
    if(metadata) {
        NSDictionary *metaForObject = [metadata objectForKey:object.objectId];

        if(metaForObject) {
            return [metaForObject objectForKey:type];
        }
    }

    return nil;
}

- (CMDistance *)distanceFromObject:(CMObject *)object {
    NSDictionary *geoData = [self metadataForObject:object ofType:CMMetadataTypeGeo];

    if(geoData) {
        return [[CMDistance alloc]
                initWithDistance:[[geoData objectForKey:@"distance"] doubleValue]
                andUnits:[geoData objectForKey:@"units"]];
    }

    return nil;
}

@end
