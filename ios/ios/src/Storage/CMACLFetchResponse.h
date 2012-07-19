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

// TODO: Doxument these

@property (strong, nonatomic) NSArray *acls;
@property (strong, nonatomic) NSDictionary *aclErrors;

- (id)initWithACLs:(NSArray *)acls errors:(NSDictionary *)errors;

- (NSSet *)allMembers;
- (NSSet *)permissionsForAllMembers;
- (NSSet *)getPermissionsForMember:(CMUser *)member;
- (NSSet *)getMemebersWithPermissions:(NSSet *)permissions;

@end
