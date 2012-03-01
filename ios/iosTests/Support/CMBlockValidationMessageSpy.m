//
//  CMBlockValidationMessageSpy.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMBlockValidationMessageSpy.h"

@implementation CMBlockValidationMessageSpy

- (id)init {
    if (self = [super init]) {
        validationToSelectorMappings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addValidationBlock:(void (^)(NSInvocation *))validationBlock forSelector:(SEL)selector {
    NSString *selName = NSStringFromSelector(selector);
    NSMutableArray *validationBlocks = [validationToSelectorMappings objectForKey:selName];
    if (validationBlocks == nil) {
        validationBlocks = [[NSMutableArray alloc] init];
        [validationToSelectorMappings setObject:validationBlocks forKey:selName];
    }
    [validationBlocks addObject:validationBlock];
}

- (void)clearAllValidationBlocks {
    [validationToSelectorMappings removeAllObjects];
}

- (void)object:(id)object didReceiveInvocation:(NSInvocation *)invocation {
    NSString *selName = NSStringFromSelector(invocation.selector);
    NSMutableArray *validationBlocks = [validationToSelectorMappings objectForKey:selName];
    if (validationBlocks != nil) {
        for (void (^block)(NSInvocation *) in validationBlocks) {
            block(invocation);
        }
    }
}

@end
