//
//  CMDate.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <objc/runtime.h>
#import "CMDate.h"
#import "CMObjectSerialization.h"

NSString * const CMDateClassName = @"datetime";

@implementation CMDate

- (id)init {
    return [self initWithDate:[NSDate date]];
}

- (id)initWithDate:(NSDate *)theDate {
    NSAssert([theDate isKindOfClass:[NSDate class]], @"Must provide NSDate to CMDate constructor.");
    if (self = [super init]) {
        _date = [theDate copy];
    }
    return self;
}

- (NSDate *)date {
    return [_date copy];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _date;
}

+ (NSTimeInterval)timeIntervalSinceReferenceDate {
    return [NSDate timeIntervalSinceReferenceDate];
}

- (NSTimeInterval)timeIntervalSinceReferenceDate {
    return [_date timeIntervalSinceReferenceDate];
}

- (BOOL)isEqualToDate:(NSDate *)otherDate {
    if ([otherDate isMemberOfClass:[CMDate class]]) {
        return (ceil([_date timeIntervalSince1970]) == ceil([[otherDate valueForKey:@"_date"] timeIntervalSince1970]));
    } else {
        return (ceil([_date timeIntervalSince1970]) == ceil([otherDate timeIntervalSince1970]));
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isMemberOfClass:[CMDate class]] && ![object isKindOfClass:[NSDate class]]) {
        return NO;
    } else {
        return [self isEqualToDate:object];
    }
}

#pragma mark - NSSerializable methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithDate:[NSDate dateWithTimeIntervalSince1970:[aDecoder decodeDoubleForKey:@"timestamp"]]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:[_date timeIntervalSince1970] forKey:@"timestamp"];
}

- (NSString *)objectId {
    return nil;
}

+ (NSString *)className {
    return CMDateClassName;
}

@end
