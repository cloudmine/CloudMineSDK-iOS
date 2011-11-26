//
//  CMObject.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"
#import "NSString+UUID.h"

@implementation CMObject

#pragma mark - Turnkey serialization methods

- (id)init {
    if (self = [super init]) {
        _objectId = [NSString stringWithUUID];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
}

- (NSString *)objectId {
    return nil;
}

- (NSString *)className {
    return NSStringFromClass([self class]);
}

@end
