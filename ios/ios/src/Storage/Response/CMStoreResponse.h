//
//  CMStoreResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMSnippetResult.h"
#import "CMResponseMetadata.h"

/**
 * Superclass for all CloudMine API responses sent by the CMStore. Contains metadata and a snippet result.
 */
@interface CMStoreResponse : NSObject

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) CMResponseMetadata *metadata;
@property (strong, nonatomic) CMSnippetResult *snippetResult;

- (id)initWithMetadata:(CMResponseMetadata *)metadata snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithError:(NSError *)error;

@end
