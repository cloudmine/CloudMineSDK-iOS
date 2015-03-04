//
//  CMObjectClassNameRegistrySpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/26/14.
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMObjectClassNameRegistry.h"
#import "CMTestEncoder.h"

SPEC_BEGIN(CMObjectClassNameRegistrySpec)

describe(@"CMObjectClassNameRegistry", ^{
    
    it(@"should refresh properly after being instantiated", ^{
        CMObjectClassNameRegistry *registry = [CMObjectClassNameRegistry sharedInstance];
        NSDictionary *mappings = [registry valueForKey:@"classNameMappings"];
        [[mappings shouldNot] beNil];
        NSInteger count = [mappings count];
        [registry refreshRegistry];
        NSMutableDictionary *newMapping = [registry valueForKey:@"classNameMappings"];
        
        ///
        /// This is intersting. At runtime, cocoa will create subclasses of objects for
        /// key-value observing and accessing, depending on what is going on. Since we cannot
        /// predict (nor should we, nor do we care) these objects, we go through and remove them
        /// from the count.
        /// They have the prefix "NSKVONotifying_"
        ///
        NSMutableArray *toRemove = [NSMutableArray array];
        [newMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key hasPrefix:@"NSKVONotifying_"])
                [toRemove addObject:key];
        }];
        
        [newMapping removeObjectsForKeys:toRemove];
        
        NSInteger newCount = [newMapping count];
        [[theValue(count) should] equal:@(newCount)];
    });
    
    it(@"should find the subclasses of CMObject", ^{
        Class klass = [[CMObjectClassNameRegistry sharedInstance] classForName:@"CMTestEncoderInt"];
        [[theValue(klass == [CMTestEncoderInt class]) should] equal:@YES];
    });
    
    it(@"should find the members who implement CMCoding", ^{
        CMObjectClassNameRegistry *registry = [CMObjectClassNameRegistry sharedInstance];
        Class klass = [registry classForName:@"CMTestEncoderNSCoding"];
        [[theValue(klass == [CMTestEncoderNSCoding class]) should] equal:@YES];
        Class anotherClass = [registry classForName:@"TestEncoderDeeper"];
        [[theValue(anotherClass == [CMTestEncoderNSCodingDeeper class]) should] equal:@YES];
    });
   
});

SPEC_END
