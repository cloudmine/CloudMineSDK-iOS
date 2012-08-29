//
//  CMACL.m
//  cloudmine-ios
//
//  Created by Marc Weil on 7/2/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMACL.h"
#import "CMNullStore.h"
#import "CMObjectSerialization.h"

NSString * const CMACLReadPermission = @"r";
NSString * const CMACLUpdatePermission = @"u";
NSString * const CMACLDeletePermission = @"d";
NSString * const CMACLTypeName = @"acl";

@implementation CMACL

@synthesize members = _members;
@synthesize permissions = _permissions;

+ (NSString *)className {
    return CMACLTypeName;
}

#pragma mark - Constructors

- (id)init {
    if (self = [super init]) {
        _members = [NSSet set];
        _permissions = [NSSet set];
    }
    return self;
}

#pragma mark - Serialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _members = [NSMutableSet setWithArray:[aDecoder decodeObjectForKey:@"members"]];
        _permissions = [NSMutableSet setWithArray:[aDecoder decodeObjectForKey:@"permissions"]];
    }
    return self;
}

- (void)setPermissions:(NSSet *)permissions {
    if (permissions != _permissions) {
        NSSet *availablePermissions = [NSSet setWithObjects:CMACLReadPermission, CMACLUpdatePermission, CMACLDeletePermission, nil];

        // Reduce list of permissions to only valid values
        NSMutableSet *mutPermissions = [NSMutableSet setWithSet:permissions];
        [mutPermissions intersectSet:availablePermissions];
        permissions = [NSSet setWithSet:mutPermissions];

        _permissions = permissions;
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[_members allObjects] forKey:@"members"];
    [aCoder encodeObject:[_permissions allObjects] forKey:@"permissions"];
    [aCoder encodeObject:CMACLTypeName forKey:CMInternalTypeStorageKey];
}

- (void)save:(CMStoreObjectUploadCallback)callback {
    if ([self.store objectOwnershipLevel:self] == CMObjectOwnershipUndefinedLevel) {
        [self.store addACL:self];
    }

    [self.store saveACL:self callback:callback];
}

- (void)saveWithUser:(CMUser *)user callback:(CMStoreObjectUploadCallback)callback {
    [self save:callback];
}

- (CMObjectOwnershipLevel)ownershipLevel {
    if (self.store != nil && self.store != [CMNullStore nullStore]) {
        return [self.store objectOwnershipLevel:self];
    } else {
        return CMObjectOwnershipUndefinedLevel;
    }
}

- (void)getACLs:(CMStoreACLFetchCallback)callback {
    [NSException raise:NSInternalInconsistencyException format:@"A CMACL object cannot have any ACLs associated with it."];
}

- (void)saveACLs:(CMStoreObjectUploadCallback)callback {
    [NSException raise:NSInternalInconsistencyException format:@"A CMACL object cannot have any ACLs associated with it."];
}

- (void)removeACL:(CMACL *)acl callback:(CMStoreObjectUploadCallback)callback {
    [NSException raise:NSInternalInconsistencyException format:@"A CMACL object cannot have any ACLs associated with it."];
}

- (void)removeACLs:(NSArray *)acls callback:(CMStoreObjectUploadCallback)callback {
    [NSException raise:NSInternalInconsistencyException format:@"A CMACL object cannot have any ACLs associated with it."];
}

- (void)addACL:(CMACL *)acl callback:(CMStoreObjectUploadCallback)callback {
    [NSException raise:NSInternalInconsistencyException format:@"A CMACL object cannot have any ACLs associated with it."];
}

- (void)addACLs:(NSArray *)acls callback:(CMStoreObjectUploadCallback)callback {
    [NSException raise:NSInternalInconsistencyException format:@"A CMACL object cannot have any ACLs associated with it."];
}

@end
