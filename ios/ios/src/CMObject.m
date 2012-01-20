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

- (id)init {
    return [self initWithObjectId:[NSString stringWithUUID]];
}

- (id)initWithObjectId:(NSString *)theObjectId {
    if (self = [super init]) {
        objectId = theObjectId;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        objectId = [aDecoder decodeObjectForKey:CM_INTERNAL_OBJECTID_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.objectId forKey:CM_INTERNAL_OBJECTID_KEY];
}

- (NSString *)objectId {
    return objectId;
}

- (NSString *)className {
    return NSStringFromClass([self class]);
}

- (BOOL)isEqual:(id)object {
    return [self.objectId isEqualToString:[object objectId]];
}

@end
