//
//  CMDeleteResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"

/**
 * Response object returned after a delete request.
 */
@interface CMDeleteResponse : CMStoreResponse

/**
 * Dictionary keyed on object id, indicating that the deletion was successful.
 */
@property (strong, nonatomic) NSDictionary *success;
/**
 * Dictionary keyed on object id, indicting which objects had errors.
 */
@property (strong, nonatomic) NSDictionary *objectErrors;

- (instancetype)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors;
- (instancetype)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult;
- (instancetype)initWithSuccess:(NSDictionary *)success errors:(NSDictionary *)errors snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
