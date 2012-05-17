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

/**
 * Dictionary keyed on object id, indicating that the deletion was successful.
 */
@property (strong, atomic) NSDictionary *success;
/**
 * Dictionary keyed on object id, indicting which objects had errors.
 */
@property (strong, atomic) NSDictionary *errors;

- (id)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors;
- (id)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
