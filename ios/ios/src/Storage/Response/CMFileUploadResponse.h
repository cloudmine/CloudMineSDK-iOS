//
//  CMFileUploadResponse.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"
#import "CMFileUploadResult.h"

@interface CMFileUploadResponse : CMStoreResponse

@property CMFileUploadResult result;
@property (strong, atomic) NSString *key;

- (id)initWithResult:(CMFileUploadResult)result key:(NSString *)key;
- (id)initWithResult:(CMFileUploadResult)result key:(NSString *)key snippetResult:(CMSnippetResult *)snippetResult;
- (id)initWithResult:(CMFileUploadResult)result key:(NSString *)key snippetResult:(CMSnippetResult *)snippetResult responseMetadata:(CMResponseMetadata *)metadata;

@end
