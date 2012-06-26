//
//  CMUntypedObject.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMUntypedObject.h"
#import "CMObjectSerialization.h"

@implementation CMUntypedObject

@synthesize fields;

- (id)initWithFields:(NSDictionary *)theFields objectId:(NSString *)objId {
    if (self = [super initWithObjectId:objId]) {
        self.fields = theFields;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.objectId forKey:CMInternalObjectIdKey];

    for (id key in fields) {
        [aCoder encodeObject:[fields objectForKey:key] forKey:key];
    }
}

@end
