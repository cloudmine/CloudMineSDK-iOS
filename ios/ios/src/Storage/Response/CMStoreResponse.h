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

@interface CMStoreResponse : NSObject

@property (strong, atomic) CMResponseMetadata *metadata;
@property (strong, atomic) CMSnippetResult *snippetResult;

- (id)initWithMetadata:(CMResponseMetadata *)metadata snippetResult:(CMSnippetResult *)snippetResult;

@end
