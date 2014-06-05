//
//  CMObjectClassNameRegistry.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectClassNameRegistry.h"
#import "CMObject.h"
#import "CMCoding.h"
#import "MARTNSObject.h"
#import <objc/runtime.h>

@implementation CMObjectClassNameRegistry

#pragma mark - Singleton methods

+ (id)sharedInstance;
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Public interface

- (Class)classForName:(NSString *)name;
{
    NSString *className = [classNameMappings objectForKey:name];
    if (className) {
        return NSClassFromString(className);
    } else {
        return nil;
    }
}

- (void)refreshRegistry;
{
    [classNameMappings removeAllObjects];
    [self discoverCMObjectSubclasses];
    [self discoverCMCodingImplementors];
}

#pragma mark - Private initializers

- (id)init;
{
    if (self = [super init]) {
        classNameMappings = [[NSMutableDictionary alloc] init];
        [self refreshRegistry];
    }
    return self;
}

#pragma mark - Private workhorse methods

- (void)discoverCMObjectSubclasses;
{
    NSArray *cmObjectSubclasses = [CMObject rt_subclasses];
    for (Class klass in cmObjectSubclasses) {
        [classNameMappings setObject:NSStringFromClass(klass) forKey:[klass className]];
    }
}

- (void)discoverCMCodingImplementors;
{
    int numClasses;
    Class *classes = NULL;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class nextClass = classes[i];
            if (class_conformsToProtocol(nextClass, @protocol(CMCoding))) {
                NSString *className = NSStringFromClass(nextClass);
                if ([nextClass respondsToSelector:@selector(className)]) {
                    className = [nextClass className];
                }
                [classNameMappings setObject:NSStringFromClass(nextClass) forKey:className];
            }
        }
        free(classes);
    }
}

@end
