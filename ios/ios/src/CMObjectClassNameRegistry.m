//
//  CMObjectClassNameRegistry.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectClassNameRegistry.h"

#import "CMObject.h"
#import "MARTNSObject.h"

@interface CMObjectClassNameRegistry (Private)
- (void)discoverCMObjectSubclasses;
@end

@implementation CMObjectClassNameRegistry

#pragma mark - Singleton methods

+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Public interface

- (Class)classForName:(NSString *)name {
    NSString *className = [classNameMappings objectForKey:name];
    if (className) {
        return NSClassFromString(className);
    } else {
        return nil;
    }
}

- (void)refreshRegistry {
    [classNameMappings removeAllObjects];
    [self discoverCMObjectSubclasses];
}

#pragma mark - Private initializers

- (id)init {
    if (self = [super init]) {
        classNameMappings = [[NSMutableDictionary alloc] init];
        [self discoverCMObjectSubclasses];
    }
    return self;
}

#pragma mark - Private workhorse methods

- (void)discoverCMObjectSubclasses {
    NSArray *cmObjectSubclasses = [CMObject rt_subclasses];
    for (Class klass in cmObjectSubclasses) {
        [classNameMappings setObject:NSStringFromClass(klass) forKey:[klass className]];
    }
}

@end
