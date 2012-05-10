//
//  CMDeleteResponse.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
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
