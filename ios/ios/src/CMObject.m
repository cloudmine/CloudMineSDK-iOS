//
//  CMObject.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"

@implementation CMObject

#pragma mark - Turnkey JSON serialization methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [super init];
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
