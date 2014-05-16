//
//  CMObject.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"
#import "CMObject+Private.h"

#import "CMNullStore.h"
#import "CMACL.h"
#import "NSString+UUID.h"
#import "CMObjectSerialization.h"
#import "CMObjectDecoder.h"

#import "MARTNSObject.h"
#import "RTProperty.h"

@implementation CMObject
@synthesize objectId;
@synthesize ownerId;
@synthesize store;
@synthesize dirty;
@synthesize aclIds;

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
        self.aclIds = [aDecoder decodeObjectForKey:CMInternalObjectACLsKey];
        if ([aDecoder isKindOfClass:[CMObjectDecoder class]]) {
            dirty = NO;
        }
    }
    return self;
}

- (void)dealloc {
    [self deregisterAllPropertiesForKVO];
}

- (NSString *)ownerId {
    if (!ownerId)
        ownerId = self.store.user.objectId;
    return ownerId;
}

#pragma mark - Dirty tracking

- (void)executeBlockForAllUserDefinedProperties:(void (^)(RTProperty *property))block {
    // Add every property on the class, up the class hierarchy the CMObject
    NSMutableArray *allProperties = [NSMutableArray array];
    for (Class class = [self class]; [class isSubclassOfClass:[CMObject class]]; class = [class superclass]) {
        [allProperties addObjectsFromArray:[class rt_properties]];
    }

    // Remove all properties on CMObject itself, minus aclIDs
    [[[CMObject class] rt_properties] enumerateObjectsUsingBlock:^(RTProperty *property, NSUInteger idx, BOOL *stop) {
        if (![[property name] isEqualToString:@"aclIds"]) {
            [allProperties removeObject:property];
        }
    }];

    [allProperties enumerateObjectsUsingBlock:^(RTProperty *property, NSUInteger idx, BOOL *stop) { block(property); }];
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
    [aCoder encodeObject:self.aclIds forKey:CMInternalObjectACLsKey];
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
                    if ([self isKindOfClass:[CMACL class]])
                        [store addACL:(CMACL *)self];
                    else
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
                    if ([self isKindOfClass:[CMACL class]])
                        [store removeACL:(CMACL *)self];
                    else
                        [store removeUserObject:self];

                    store = newStore;

                    if ([self isKindOfClass:[CMACL class]])
                        [store addACL:(CMACL *)self];
                    else
                        [store addUserObject:self];
                    break;
                default:
                    store = newStore;
                    [store addObject:self];
                    break;
            }
        }
    }
}

#pragma mark - ACLs

- (void)getACLs:(CMStoreACLFetchCallback)callback {
    NSAssert([self.store objectOwnershipLevel:self] == CMObjectOwnershipUserLevel, @"*** Error: Object %@ is not at the user level. It must be a user level object in order for it to have ACLs.", self);

    if (self.sharedACL) {
        CMACLFetchResponse *response = [[CMACLFetchResponse alloc] initWithACLs:[NSSet setWithObject:self.sharedACL] errors:nil];
        callback(response);
        return;
    }

    [self.store allACLs:^(CMACLFetchResponse *response) {
        NSMutableSet *acls = [NSMutableSet set];
        [response.acls enumerateObjectsUsingBlock:^(CMACL *acl, BOOL *stop) {
            if ([self.aclIds containsObject:acl.objectId])
                [acls addObject:acl];
        }];
        response.acls = [acls copy];
        callback(response);
    }];
}

- (void)saveACLs:(CMStoreObjectUploadCallback)callback {
    NSAssert([self.store objectOwnershipLevel:self] == CMObjectOwnershipUserLevel, @"*** Error: Object %@ is not at the user level. It must be a user level object in order for it to have ACLs.", self);
    if (self.sharedACL) {
        NSError *ownerError = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Object %@ is not owned by the user configured with the store. You must have ownership of the object in order to save any ACLs.", NSLocalizedDescriptionKey, nil]];
        CMObjectUploadResponse *response = [[CMObjectUploadResponse alloc] initWithError:ownerError];
        callback(response);
        return;
    }
    [self.store saveACLsOnObject:self callback:callback];
}

- (void)removeACL:(CMACL *)acl callback:(CMStoreObjectUploadCallback)callback {
    [self removeACLs:[NSArray arrayWithObject:acl] callback:callback];
}

- (void)removeACLs:(NSArray *)acls callback:(CMStoreObjectUploadCallback)callback {
    NSAssert([self.store objectOwnershipLevel:self] == CMObjectOwnershipUserLevel, @"*** Error: Object %@ is not at the user level. It must be a user level object in order for it to have ACLs.", self);
    if (self.sharedACL) {
        NSError *ownerError = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Object %@ is not owned by the user configured with the store. You must have ownership of the object in order to remove ACLs.", NSLocalizedDescriptionKey, nil]];
        CMObjectUploadResponse *response = [[CMObjectUploadResponse alloc] initWithError:ownerError];
        callback(response);
        return;
    }

    NSMutableArray *objectIds = [self.aclIds mutableCopy];
    [objectIds removeObjectsInArray:[acls valueForKey:@"objectId"]];
    self.aclIds = [objectIds copy];
    [self save:callback];
}

- (void)addACL:(CMACL *)acl callback:(CMStoreObjectUploadCallback)callback {
    [self addACLs:[NSArray arrayWithObject:acl] callback:callback];
}

- (void)addACLs:(NSArray *)acls callback:(CMStoreObjectUploadCallback)callback {
    NSAssert([self.store objectOwnershipLevel:self] == CMObjectOwnershipUserLevel, @"*** Error: Object %@ is not at the user level. It must be a user level object in order for it to have ACLs.", self);
    if (self.sharedACL) {
        NSError *ownerError = [NSError errorWithDomain:CMErrorDomain code:CMErrorInvalidRequest userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Object %@ is not owned by the user configured with the store. You must have ownership of the object in order to add ACLs.", NSLocalizedDescriptionKey, nil]];
        CMObjectUploadResponse *response = [[CMObjectUploadResponse alloc] initWithError:ownerError];
        callback(response);
        return;
    }

    [self.store saveACLs:acls callback:^(CMObjectUploadResponse *saveResponse) {
        // Add saved ACLs to `aclIds` property
        NSMutableArray *objectIds = self.aclIds ? [self.aclIds mutableCopy] : [NSMutableArray array];
        NSSet *keys = [saveResponse.uploadStatuses keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
            return [obj isEqualToString:@"updated"];
        }];
        [keys enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            if (![objectIds containsObject:obj])
                [objectIds addObject:obj];
        }];
        self.aclIds = [objectIds copy];

        // Save object and send merged response back in callback
        [self save:^(CMObjectUploadResponse *response) {
            NSMutableDictionary *statuses = [NSMutableDictionary dictionaryWithDictionary:response.uploadStatuses];
            [statuses addEntriesFromDictionary:saveResponse.uploadStatuses];
            response.uploadStatuses = statuses;
            callback(response);
        }];
    }];
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

- (NSString *)description;
{
    NSString *string = [[NSString alloc] init];
    
    NSArray *properties = [[self class] rt_properties];
    
    for (RTProperty *prop in properties) {
        string = [string stringByAppendingFormat:@"\n%@: %@", prop.name, [self valueForKey:prop.name]];
    }
    
    return string;
}

@end
