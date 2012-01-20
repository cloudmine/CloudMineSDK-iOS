//
//  ClassPropertyExtractor.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//
//  The contents of this partially class taken from the example on StackOverflow found at
//  http://stackoverflow.com/a/8380836/102529
//

#import "CMClassPropertyExtractor.h"
#import "objc/runtime.h"

@implementation CMClassPropertyExtractor

+ (NSSet *)propertiesForClass:(Class)klass {    
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableSet *results = [[NSMutableSet alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [results addObject:propertyName];
        }
    }
    free(properties);
    
    return results;
}

@end
