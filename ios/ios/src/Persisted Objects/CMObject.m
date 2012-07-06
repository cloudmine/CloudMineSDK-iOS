//
//  CMObject.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMNullStore.h"
#import "CMObject.h"
#import "NSString+UUID.h"
#import "CMObjectSerialization.h"
#import "CMObjectDecoder.h"

#import "MARTNSObject.h"
#import "RTProperty.h"

@interface CMObject ()
@property (readwrite, getter = isDirty) BOOL dirty;
@end

@implementation CMObject
@synthesize objectId;
@synthesize store;
@synthesize dirty;

#pragma mark - Initializers

- (id)init {
    return [self initWithObjectId:[NSString stringWithUUID]];
}

- (id)initWithObjectId:(NSString *)theObjectId {
    if (self = [super init]) {
        objectId = theObjectId;
        store = nil;
        dirty = YES;
        [self registerAllPropertiesForKVO];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    id deserializedObjectId = [aDecoder decodeObjectForKey:CMInternalObjectIdKey];
    if (![deserializedObjectId isKindOfClass:[NSString class]])
        deserializedObjectId = [deserializedObjectId stringValue];

    if (self = [self initWithObjectId:deserializedObjectId]) {
        if ([aDecoder isKindOfClass:[CMObjectDecoder class]]) {
            dirty = NO;
        }
    }
    return self;
}

- (void)dealloc {
    [self deregisterAllPropertiesForKVO];
}

#pragma mark - Dirty tracking

- (void)executeBlockForAllUserDefinedProperties:(void (^)(RTProperty *property))block {
    NSArray *allProperties = [[self class] rt_properties];
    NSArray *superclassProperties = [[CMObject class] rt_properties];
    [allProperties enumerateObjectsUsingBlock:^(RTProperty *property, NSUInteger idx, BOOL *stop) {
        if (![superclassProperties containsObject:property]) {
            block(property);
        }
    }];
}

- (void)registerAllPropertiesForKVO {
    [self executeBlockForAllUserDefinedProperties:^(RTProperty *property) {
        [self addObserver:self forKeyPath:[property name] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }];
}

- (void)deregisterAllPropertiesForKVO {
    [self executeBlockForAllUserDefinedProperties:^(RTProperty *property) {
        [self removeObserver:self forKeyPath:[property name]];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (![oldValue isEqual:newValue]) {
        dirty = YES;
    }
}

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.objectId forKey:CMInternalObjectIdKey];
}

#pragma mark - CMStore interactions

- (void)save:(CMStoreObjectUploadCallback)callback {
    if ([self.store objectOwnershipLevel:self] == CMObjectOwnershipUndefinedLevel) {
        [self.store addObject:self];
    }
    
    switch ([self.store objectOwnershipLevel:self]) {
        case CMObjectOwnershipAppLevel:
            [self.store saveObject:self callback:callback];
            break;
        case CMObjectOwnershipUserLevel:
            [self.store saveUserObject:self callback:callback];
            break;
        default:
            NSLog(@"*** Error: Could not save object (%@) because no store was set. This should never happen!", self);
            break;
    }
}

- (void)saveWithUser:(CMUser *)user callback:(CMStoreObjectUploadCallback)callback {
    NSAssert([self.store objectOwnershipLevel:self] != CMObjectOwnershipAppLevel, @"*** Error: Object %@ is already at the app-level. You cannot also save it to the user level. Make a copy of it with a new objectId to do this.", self);
    if ([self.store objectOwnershipLevel:self] == CMObjectOwnershipUndefinedLevel) {
        [self.store addUserObject:self];
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
            // An object without a store is kind of in a weird state. So represent this
            // with a null store that throws exceptions whenever anything is called on it.
            store = [CMNullStore nullStore];
            return;
        } else if(!store || store == [CMNullStore nullStore]) {
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
    if (self.store != nil && self.store != [CMNullStore nullStore]) {
        return [self.store objectOwnershipLevel:self];
    } else {
        return CMObjectOwnershipUndefinedLevel;
    }
}

@end
