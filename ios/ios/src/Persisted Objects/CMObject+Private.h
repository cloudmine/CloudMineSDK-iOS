//
//  CMObject+Private.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"

@class CMACL;

@interface CMObject ()
@property (readwrite, getter = isDirty) BOOL dirty;
@property (readwrite, strong, nonatomic) NSString *ownerId;
@property (strong, nonatomic) CMACL *sharedACL;
@property (strong, nonatomic) NSArray *aclIds;
@end