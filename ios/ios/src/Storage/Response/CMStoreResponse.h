//
//  CMStoreResponse.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMSnippetResult.h"
#import "CMResponseMetadata.h"

@interface CMStoreResponse : NSObject

@property (strong, atomic) CMResponseMetadata *metadata;
@property (strong, atomic) CMSnippetResult *snippetResult;

- (id)initWithMetadata:(CMResponseMetadata *)metadata snippetResult:(CMSnippetResult *)snippetResult;

@end
