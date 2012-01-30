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
#import "CMUser.h"
#import "CMStore.h"

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

- (void)save:(CMStoreUploadCallback)callback {
    NSAssert([self belongsToStore], @"You cannot save an object (%@) that doesn't belong to a CMStore.", self);
    [store saveObject:self callback:callback];
}

- (BOOL)belongsToStore {
    return (store != nil);
}

- (void)setStore:(CMStore *)theStore {
    NSParameterAssert(theStore);
    
    @synchronized(self) {
        if (store) {
            // Remove this object from the current store.
            [store removeObject:self];
        }
        
        // Add this object to the new store and record that relationship.
        [theStore addObject:self];
        self.store = theStore;
    }
}

#pragma mark - Accessors

+ (NSString *)className {
    return NSStringFromClass(self);
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[CMObject class]] && [self.objectId isEqualToString:[object objectId]];
}

@end
