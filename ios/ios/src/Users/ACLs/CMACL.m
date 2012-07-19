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

@implementation CMACL {
    NSMutableSet *_members;
    NSMutableSet *_permissions;
}

@synthesize members = _members;
@synthesize permissions = _permissions;

+ (NSString *)className {
    return CMACLTypeName;
}

#pragma mark - Constructors

- (id)init {
    if (self = [super init]) {
        _members = [NSMutableSet set];
        _permissions = [NSMutableSet set];
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

@end
