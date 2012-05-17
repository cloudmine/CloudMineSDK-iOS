//
//  CMResponseMetadata.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMDistance.h"

@class CMObject;

extern NSString * const CMMetadataTypeGeo;

@interface CMResponseMetadata : NSObject

- (id)initWithMetadata:(NSDictionary *)data;
/**
 * Returns raw metadata. This method should not be necessary; you should try to use specialized methods like distanceFromObject if possible.
 *
 * @param object The object whose metadata we're looking for.
 * @param type The type of metadata to extract.
 */
- (NSDictionary *)metadataForObject:(CMObject *)object ofType:(NSString *)type;

/**
 * Given an object fetched with a distance query, returns the distance from that object to the point given in the query.
 *
 * @param object Indicates which object should be checked
 */
- (CMDistance *)distanceFromObject:(CMObject *)object;

@end
