//
//  CMBlockValidationMessageSpy.h
//  cloudmine-iosTests
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "Kiwi.h"

@interface CMBlockValidationMessageSpy : NSObject <KWMessageSpying> {
    NSMutableDictionary *validationToSelectorMappings;
}

- (void)addValidationBlock:(void (^)(NSInvocation *invocation))validationBlock forSelector:(SEL)selector;
- (void)clearAllValidationBlocks;

@end
