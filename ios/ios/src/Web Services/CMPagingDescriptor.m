//
//  CMPagingDescriptor.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMPagingDescriptor.h"

NSString * const CMPagingDescriptorLimitKey = @"limit";
NSString * const CMPagingDescriptorSkipKey = @"skip";
NSString * const CMPagingDescriptorCountKey = @"count";

#define DEFAULT_LIMIT 50
#define DEFAULT_OFFSET 0
#define DEFAULT_INCLUDE_COUNT NO

@implementation CMPagingDescriptor

#pragma mark - Initializers

+ (id)defaultPagingDescriptor {
    return [[self alloc] init];
}

- (id)init {
    return [self initWithLimit:DEFAULT_LIMIT skip:DEFAULT_OFFSET includeCount:DEFAULT_INCLUDE_COUNT];
}

- (id)initWithLimit:(NSInteger)theLimit {
    return [self initWithLimit:theLimit skip:DEFAULT_OFFSET includeCount:DEFAULT_INCLUDE_COUNT];
}

- (id)initWithLimit:(NSInteger)theLimit skip:(NSUInteger)theOffset {
    return [self initWithLimit:theLimit skip:theOffset includeCount:DEFAULT_INCLUDE_COUNT];
}

- (id)initWithLimit:(NSInteger)theLimit skip:(NSUInteger)theOffset includeCount:(BOOL)willIncludeCount {
    if (self = [super init]) {
        self.limit = theLimit;
        self.skip = theOffset;
        self.includeCount = willIncludeCount;
    }
    return self;
}

#pragma mark - Consumable representations

- (NSDictionary *)dictionaryRepresentation {
    return @{CMPagingDescriptorLimitKey: @(self.limit),
             CMPagingDescriptorSkipKey: @(self.skip),
             CMPagingDescriptorCountKey: @(self.includeCount)};
}

- (NSString *)stringRepresentation {
    NSString *limitString = [NSString stringWithFormat:@"%@=%li", CMPagingDescriptorLimitKey, (long)_limit];
    NSString *skipString = [NSString stringWithFormat:@"%@=%lu", CMPagingDescriptorSkipKey, (unsigned long)_skip];
    NSString *countString = [NSString stringWithFormat:@"%@=%@", CMPagingDescriptorCountKey, _includeCount ? @"true" : @"false"];

    return [@[limitString, skipString, countString] componentsJoinedByString:@"&"];
}

@end
