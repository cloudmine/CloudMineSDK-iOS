//
//  CMACLFetchResponse.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStoreResponse.h"
#import "CMUser.h"

@interface CMACLFetchResponse : CMStoreResponse

/**
 * A set of all the ACLs fetched from the server.
 */
@property (strong, nonatomic, nullable) NSSet *acls;

/**
 * A dictionary of errors that occurred fetching ACLs from the server. It is keyed by object ID.
 */
@property (strong, nonatomic, nullable) NSDictionary *aclErrors;

- (nonnull instancetype)initWithACLs:(nullable NSSet *)acls errors:(nullable NSDictionary *)errors;

/**
 * Returns a set of every user, unioned from every ACL.
 */
- (nonnull NSSet *)allMembers;

/**
 * Returns a set of permissions thay every ACL has in common, an empty set if none.
 */
- (nonnull NSSet *)permissionsForAllMembers;

/**
 * Returns the maxmimum permissions of a user, unioned from every ACL in this response that he is also a member of.
 *
 * @param member The member to retrieve permissions for
 */
- (nonnull NSSet *)permissionsForMember:(nonnull NSString *)member;

/**
 * Returns the list of all users with at least the specified permissions.
 *
 * @param permissions The set of permissions that the returned users are guaranteed to have.
 */
- (nonnull NSSet *)membersWithPermissions:(nonnull NSSet *)permissions;

@end
