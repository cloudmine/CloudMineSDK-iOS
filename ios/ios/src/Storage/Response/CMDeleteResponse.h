//
//  CMDeleteResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

@interface CMDeleteResponse : CMStoreResponse

@property (strong, atomic) NSDictionary *success;
@property (strong, atomic) NSDictionary *errors;

- (id)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors;
- (id)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
