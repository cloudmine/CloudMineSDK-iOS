//
//  CMObjectFetchResponse.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

@interface CMObjectFetchResponse : CMStoreResponse

@property (strong, atomic) NSArray *objects;
@property (strong, atomic) NSDictionary *errors;

- (id)initWithObjects:(NSArray *)objects errors:(NSDictionary *)errors;
- (id)initWithObjects:(NSArray *)objects errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithObjects:(NSArray *)objects errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
