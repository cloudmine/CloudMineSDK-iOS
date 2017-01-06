//
//  CMStoreResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMSnippetResult.h"
#import "CMResponseMetadata.h"

/**
 * Superclass for all CloudMine API responses sent by the CMStore. Contains metadata and a snippet result.
 */
@interface CMStoreResponse : NSObject

@property (strong, nonatomic, nullable) NSError *error;
@property (strong, nonatomic, nullable) CMResponseMetadata *metadata;
@property (strong, nonatomic, nullable) CMSnippetResult *snippetResult;

- (nonnull instancetype)initWithMetadata:(nullable CMResponseMetadata *)metadata snippetResult:(nullable CMSnippetResult *)snippetResult;
- (nonnull instancetype)initWithError:(nullable NSError *)error;

@end
