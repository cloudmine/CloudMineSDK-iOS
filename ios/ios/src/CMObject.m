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

@implementation CMObject
@synthesize objectId;
@synthesize user;

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
        user = theUser;
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

#pragma mark - Accessors

- (BOOL)isUserLevel {
    return (user != nil);
}

- (NSString *)className {
    return NSStringFromClass([self class]);
}

- (BOOL)isEqual:(id)object {
    return [self.objectId isEqualToString:[object objectId]];
}

@end
