//
//  CMStoreOptions.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@class CMPagingDescriptor;
@class CMServerFunction;

@interface CMStoreOptions : NSObject

@property (nonatomic, strong) CMPagingDescriptor *pagingDescriptor;
@property (nonatomic, strong) CMServerFunction *serverSideFunction;

- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor;
- (id)initWithServerSideFunction:(CMServerFunction *)theServerFunction;
- (id)initWithPagingDescriptor:(CMPagingDescriptor *)thePagingDescriptor 
         andServerSideFunction:(CMServerFunction *)theServerFunction;

- (NSString *)stringRepresentation;

@end
