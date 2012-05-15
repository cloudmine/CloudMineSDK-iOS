//
//  CMSortDescriptor.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMSortDescriptor.h"

@implementation CMSortDescriptor {
    NSMutableDictionary *fieldToDirectionMapping;
}

- (id)init {
    if (self = [super init]) {
        fieldToDirectionMapping = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithFieldsAndDirections:(NSString *)fieldsAndDirections, ... {
    
    if ([self init) {
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
        
        va_end(args);
    }
    return self;
}

@end
