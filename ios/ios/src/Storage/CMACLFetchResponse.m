//
//  CMACLFetchResponse.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMACLFetchResponse.h"

#import "CMACL.h"

@implementation CMACLFetchResponse

@synthesize acls = _acls;
@synthesize aclErrors = _aclErrors;

- (id)initWithACLs:(NSSet *)acls errors:(NSDictionary *)errors {
    if ((self = [super initWithMetadata:nil snippetResult:nil])) {
        self.acls = acls;
        self.aclErrors = errors;
    }
    return self;
}

- (NSSet *)allMembers {
    // Return the total set of all users
    NSMutableSet *members = [NSMutableSet set];
    [self.acls enumerateObjectsUsingBlock:^(CMACL *acl, BOOL *stop) {
        [members unionSet:acl.members];
    }];

    return [members copy];
}

- (NSSet *)permissionsForAllMembers {
    // Return the permissions every ACL has in common
    NSMutableSet *permissions = [NSMutableSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, CMACLDeletePermission, nil];
    [self.acls enumerateObjectsUsingBlock:^(CMACL *acl, BOOL *stop) {
        [permissions intersectSet:acl.permissions];
    }];

    return [permissions copy];
}

- (NSSet *)permissionsForMember:(NSString *)user {

    // Filter the returned ACLs by user
    NSMutableSet *acls = [NSMutableSet set];
    [self.acls enumerateObjectsUsingBlock:^(CMACL *acl, BOOL *stop) {
        if ([acl.members containsObject:user])
            [acls addObject:acl];
    }];

    // Get maximum permissions for this user
    NSMutableSet *permissions = [NSMutableSet set];
    [acls enumerateObjectsUsingBlock:^(CMACL *acl, BOOL *stop) {
        [permissions unionSet:acl.permissions];
    }];

    return [permissions copy];
}

- (NSSet *)membersWithPermissions:(NSSet *)permissions {
    // Filter the returned ACLs by permission
    NSMutableSet *acls = [NSMutableSet set];
    [self.acls enumerateObjectsUsingBlock:^(CMACL *acl, BOOL *stop) {
        if ([permissions isSubsetOfSet:acl.permissions])
            [acls addObject:acl];
    }];

    // Get all of the users
    NSMutableSet *members = [NSMutableSet set];
    [acls enumerateObjectsUsingBlock:^(CMACL *acl, BOOL *stop) {
        [members unionSet:acl.members];
    }];

    return [members copy];
}

@end
