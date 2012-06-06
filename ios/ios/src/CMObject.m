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
        store = [CMStore defaultStore];
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
    switch ([store objectOwnershipLevel:self]) {
        case CMObjectOwnershipAppLevel:
            [store saveObject:self callback:callback];
            break;
        case CMObjectOwnershipUserLevel:
            [store saveUserObject:self callback:callback];
            break;
        default:
            NSLog(@"*** Could not save object (%@) because no store was set. This should never happen!", self);
            break;
    }
}

- (BOOL)belongsToStore {
    NSLog(@"-[CMObject belongsToStore] has been deprecated with the introduction of the default store. An object will always belong to a store.");
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
