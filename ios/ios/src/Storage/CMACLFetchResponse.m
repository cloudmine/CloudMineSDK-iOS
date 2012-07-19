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

- (id)initWithACLs:(NSArray *)acls errors:(NSDictionary *)errors {
    if ((self = [super initWithMetadata:nil snippetResult:nil])) {
        self.acls = acls;
        self.aclErrors = errors;
    }
    return self;
}

- (NSSet *)allMembers {
    // Return the total set of all users
    NSMutableSet *members = [NSMutableSet set];
    [self.acls enumerateObjectsUsingBlock:^(CMACL *acl, NSUInteger idx, BOOL *stop) {
        [members unionSet:acl.members];
    }];
    
    return [members copy];
}

- (NSSet *)permissionsForAllMembers {
    // Return the permissions every ACL has in common
    __block NSMutableSet *permissions = [NSMutableSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, CMACLDeletePermission, nil];
    [self.acls enumerateObjectsUsingBlock:^(CMACL *acl, NSUInteger idx, BOOL *stop) {
        [permissions intersectSet:acl.permissions];
    }];
    
    return permissions;
}

- (NSSet *)getPermissionsForMember:(CMUser *)user {
    
    // Filter the returned ACLs by user
    NSIndexSet *indexes = [self.acls indexesOfObjectsPassingTest:^(CMACL *acl, NSUInteger idx, BOOL *stop) {
        return [acl.members containsObject:user];
    }];
    NSArray *acls = [self.acls objectsAtIndexes:indexes];
    
    // Get maximum permissions for this user
    NSMutableSet *permissions = [NSMutableSet set];
    [acls enumerateObjectsUsingBlock:^(CMACL *acl, NSUInteger idx, BOOL *stop) {
        [permissions unionSet:acl.permissions];
    }];
    
    return [permissions copy];
}

- (NSSet *)getMemebersWithPermissions:(NSSet *)permissions {
    // Filter the returned ACLs by permission
    NSIndexSet *indexes = [self.acls indexesOfObjectsPassingTest:^(CMACL *acl, NSUInteger idx, BOOL *stop) {
        return [permissions isSubsetOfSet:acl.permissions];
    }];
    NSArray *acls = [self.acls objectsAtIndexes:indexes];
    
    // Get all of the users
    NSMutableSet *members = [NSMutableSet set];
    [acls enumerateObjectsUsingBlock:^(CMACL *acl, NSUInteger idx, BOOL *stop) {
        [members unionSet:acl.members];
    }];
    
    return [members copy];
}

@end
