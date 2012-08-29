//
//  CMACL.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"

extern NSString * const CMACLTypeName;

/**
 * These are the permissions that can be granted to other users. These are the only
 * permissions allowed in the set of permissions on a CMACL object
 */
extern NSString * const CMACLReadPermission;
extern NSString * const CMACLUpdatePermission;
extern NSString * const CMACLDeletePermission;

/**
 * This is a class to represent an ACL object in CloudMine's data store. CMACLs can
 * be added to CMObjects to share CMObjects with other users. The users specified in
 * the members property are granted the permissions specified in the permissions property.
 * ACLs can only be added to user-level objects, and only by the owner of those objects.
 */
@interface CMACL : CMObject

/**
 * The set of IDs of the members which are granted the permissions provided in the ACL.
 */
@property (nonatomic, strong) NSSet *members;

/**
 * The set of permissions that the members of the ACL are granted. Can be any combination of
 * read, update and delete.
 */
@property (nonatomic, strong) NSSet *permissions;

@end
