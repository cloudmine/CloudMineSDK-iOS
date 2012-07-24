//
//  CMACLFetchResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStoreResponse.h"
#import "CMUser.h"

@interface CMACLFetchResponse : CMStoreResponse

/**
 * A set of all the ACLs fetched from the server.
 */
@property (strong, nonatomic) NSSet *acls;

/**
 * A dictionary of errors that occurred fetching ACLs from the server. It is keyed by object ID.
 */
@property (strong, nonatomic) NSDictionary *aclErrors;

- (id)initWithACLs:(NSSet *)acls errors:(NSDictionary *)errors;

/**
 * Returns a set of every user, unioned from every ACL.
 */
- (NSSet *)allMembers;

/**
 * Returns a set of permissions thay every ACL has in common, an empty set if none.
 */
- (NSSet *)permissionsForAllMembers;

/**
 * Returns the maxmimum permissions of a user, unioned from every ACL in this response that he is also a member of.
 *
 * @param member The member to retrieve permissions for
 */
- (NSSet *)permissionsForMember:(NSString *)member;

/**
 * Returns the list of all users with at least the specified permissions.
 *
 * @param permissions The set of permissions that the returned users are guaranteed to have.
 */
- (NSSet *)membersWithPermissions:(NSSet *)permissions;

@end
