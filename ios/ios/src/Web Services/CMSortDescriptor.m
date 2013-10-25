//
//  CMSortDescriptor.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMSortDescriptor.h"

NSString * const CMSortAscending = @"asc";
NSString * const CMSortDescending = @"desc";

@implementation CMSortDescriptor {
    NSMutableDictionary *fieldToDirectionMapping;
}

#pragma mark - Constructors

+ (id)emptyDescriptor {
    return [[[self class] alloc] init];
}

- (id)init {
    if (self = [super init]) {
        fieldToDirectionMapping = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithFieldsAndDirections:(NSString *)fieldsAndDirections, ... {
    if ([self init]) {
        va_list args;
        va_start(args, fieldsAndDirections);

        NSString *fieldName = nil;
        for (NSString *fieldOrDirection = fieldsAndDirections; fieldOrDirection != nil; fieldOrDirection = va_arg(args, NSString*))
        {
            if (!fieldName) {
                fieldName = fieldOrDirection;
            } else {
                [fieldToDirectionMapping setObject:fieldOrDirection forKey:fieldName];
                fieldName = nil;
            }
        }

        if (fieldName != nil) {
            // If we get here, there were an odd number of parameters specified. This is programmer error.
            [[NSException exceptionWithName:@"NSInternalInconsistencyException"
                                     reason:@"There must be an even number of arguments to initWithFieldsAndDirections:. You have a mismatched pair."
                                   userInfo:nil]
             raise];
            __builtin_unreachable();
        }

        va_end(args);
    }
    return self;
}

#pragma mark - Mutators

- (void)sortByField:(NSString *)fieldName {
    [self sortByField:fieldName direction:CMSortDefault];
}

- (void)sortByField:(NSString *)fieldName direction:(id)direction {
    if (!direction) {
        direction = [NSNull null];
    }

    [fieldToDirectionMapping setObject:direction forKey:fieldName];
}

- (void)stopSortingByField:(NSString *)fieldName {
    [fieldToDirectionMapping removeObjectForKey:fieldName];
}

#pragma mark - Accessors

- (NSString *)directionOfField:(NSString *)fieldName {
    return [fieldToDirectionMapping objectForKey:fieldName];
}

- (NSUInteger)count {
    return [fieldToDirectionMapping count];
}

- (NSString *)stringRepresentation {
    NSMutableArray *pairs = [NSMutableArray array];

    [fieldToDirectionMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *descString = [NSString stringWithFormat:@"sort=%@", key];
        if (![obj isEqual:[NSNull null]]) {
            descString = [descString stringByAppendingFormat:@":%@", obj];
        }
        [pairs addObject:descString];
    }];

    return [pairs componentsJoinedByString:@"&"];
}

@end
