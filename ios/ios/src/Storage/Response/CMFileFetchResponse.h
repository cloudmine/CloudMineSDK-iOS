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

@property (strong, atomic) CMFile *file;

- (id)initWithFile:(CMFile *)file;

@end
