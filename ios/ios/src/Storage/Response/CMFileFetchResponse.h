//
//  CMFileFetchResponse.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/9/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMStoreResponse.h"
#import "CMFile.h"

@interface CMFileFetchResponse : CMStoreResponse

@property (strong, atomic) CMFile *file;

- (id)initWithFile:(CMFile *)file;

@end
