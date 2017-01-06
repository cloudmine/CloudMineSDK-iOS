//
//  CMUntypedObject.m
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMUntypedObject.h"
#import "CMObjectSerialization.h"

@implementation CMUntypedObject

@synthesize fields;

- (instancetype)initWithFields:(NSDictionary *)theFields objectId:(NSString *)objId;
{
    if ([self initWithObjectId:objId]) {
        self.fields = theFields;
    }
    return self;
}

- (instancetype)initWithObjectId:(NSString *)theObjectId;
{
    if (self = [super initWithObjectId:theObjectId]) {
        self.fields = @{};
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder; // Why is there no initWithCoder: method implemented? -bendi
{
    [super encodeWithCoder:aCoder];
    for (id key in fields) {
        [aCoder encodeObject:[fields objectForKey:key] forKey:key];
    }
}

@end
