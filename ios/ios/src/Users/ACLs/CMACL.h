//
//  CMACL.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"

extern NSString * const CMACLReadPermission;
extern NSString * const CMACLUpdatePermission;
extern NSString * const CMACLDeletePermission;
extern NSString * const CMACLTypeName;

@interface CMACL : CMObject

// TODO: Doxument this

@property (nonatomic, strong) NSSet *members;
@property (nonatomic, strong) NSSet *permissions;

@end
