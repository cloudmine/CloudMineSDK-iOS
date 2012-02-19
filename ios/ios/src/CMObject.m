//
//  CMObject.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"
#import "NSString+UUID.h"
#import "CMObjectSerialization.h"

@implementation CMObject
@synthesize objectId;
@synthesize store;

#pragma mark - Initializers

- (id)init {
    return [self initWithObjectId:[NSString stringWithUUID]];
}

- (id)initWithObjectId:(NSString *)theObjectId {
    return [self initWithObjectId:theObjectId user:nil];
}

- (id)initWithObjectId:(NSString *)theObjectId user:(CMUser *)theUser {
    if (self = [super init]) {
        objectId = theObjectId;
        store = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithObjectId:[aDecoder decodeObjectForKey:CMInternalObjectIdKey]];
}

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.objectId forKey:CMInternalObjectIdKey];
}

#pragma mark - CMStore interactions

- (void)save:(CMStoreObjectUploadCallback)callback {
    NSAssert([self belongsToStore], @"You cannot save an object (%@) that doesn't belong to a CMStore.", self);
    [store saveObject:self callback:callback];
}

- (BOOL)belongsToStore {
    return (store != nil);
}

- (CMStore *)store {
    if (store && [store objectOwnershipLevel:self] == CMObjectOwnershipUndefinedLevel) {
        store = nil;
    }
    return store;
}

#pragma mark - Accessors

+ (NSString *)className {
    return NSStringFromClass(self);
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[CMObject class]] && [self.objectId isEqualToString:[object objectId]];
}

- (CMObjectOwnershipLevel)ownershipLevel {
    if (self.store != nil) {
        return [self.store objectOwnershipLevel:self];
    } else {
        return CMObjectOwnershipUndefinedLevel;
    }
}

@end
