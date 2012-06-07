//
//  CMObject.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
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
    if (self = [super init]) {
        objectId = theObjectId;
        store = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    id deserializedObjectId = [aDecoder decodeObjectForKey:CMInternalObjectIdKey];

    if (![deserializedObjectId isKindOfClass:[NSString class]]) {
        deserializedObjectId = [deserializedObjectId stringValue];
    }

    return [self initWithObjectId:deserializedObjectId];
}

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.objectId forKey:CMInternalObjectIdKey];
}

#pragma mark - CMStore interactions

- (void)save:(CMStoreObjectUploadCallback)callback {
    if ([store objectOwnershipLevel:self] == CMObjectOwnershipUndefinedLevel) {
        [store addObject:self];
    }

    switch ([store objectOwnershipLevel:self]) {
        case CMObjectOwnershipAppLevel:
            [store saveObject:self callback:callback];
            break;
        case CMObjectOwnershipUserLevel:
            [store saveUserObject:self callback:callback];
            break;
        default:
            NSLog(@"*** Error: Could not save object (%@) because no store was set. This should never happen!", self);
            break;
    }
}

- (void)saveWithUser:(CMUser *)user callback:(CMStoreObjectUploadCallback)callback {
    NSAssert([store objectOwnershipLevel:self] == CMObjectOwnershipAppLevel, @"*** Error: Object %@ is already at the app-level. You cannot also save it to the user level. Make a copy of it with a new objectId to do this.", self);
    if ([store objectOwnershipLevel:self] == CMObjectOwnershipUndefinedLevel) {
        [store addUserObject:self];
    }
    [self save:callback];
}

- (BOOL)belongsToStore {
    NSLog(@"-[CMObject belongsToStore] has been deprecated with the introduction of the default store. An object will always belong to a store.");
    return YES;
}

- (CMStore *)store {
    if (!store) {
        return [CMStore defaultStore];
    }
    return store;
}

- (void)setStore:(CMStore *)newStore {
    @synchronized(self) {
        if(!newStore) {
            store = nil;
            return;
        } else if(!store) {
            switch ([newStore objectOwnershipLevel:self]) {
                case CMObjectOwnershipAppLevel:
                    store = newStore;
                    [store addObject:self];
                    break;
                case CMObjectOwnershipUserLevel:
                    store = newStore;
                    [store addUserObject:self];
                    break;
                default:
                    store = newStore;
                    [store addObject:self];
                    break;
            }

            return;
        } else if (newStore != store) {
            switch ([store objectOwnershipLevel:self]) {
                case CMObjectOwnershipAppLevel:
                    [store removeObject:self];
                    store = newStore;
                    [newStore addObject:self];
                    break;
                case CMObjectOwnershipUserLevel:
                    [store removeUserObject:self];
                    store = newStore;
                    [newStore addUserObject:self];
                    break;
                default:
                    store = newStore;
                    [store addObject:self];
                    break;
            }
        }
    }
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
