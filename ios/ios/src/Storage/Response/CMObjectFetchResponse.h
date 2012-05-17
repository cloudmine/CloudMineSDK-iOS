//
//  CMObjectFetchResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

@interface CMObjectFetchResponse : CMStoreResponse

/**
 * The objects returned by the CloudMine API. These will all inherit from CMSerializable.
 */
@property (strong, atomic) NSArray *objects;
/**
 * Errors returned from the API.
 */
@property (strong, atomic) NSDictionary *errors;

- (id)initWithObjects:(NSArray *)objects errors:(NSDictionary *)errors;
- (id)initWithObjects:(NSArray *)objects errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithObjects:(NSArray *)objects errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
