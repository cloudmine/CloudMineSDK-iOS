//
//  CMFileFetchResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"
#import "CMFile.h"

@interface CMFileFetchResponse : CMStoreResponse

/**
 * The file that was fetched.
 */
@property (strong, nonatomic) CMFile *file;

- (id)initWithFile:(CMFile *)file;

@end
