//
//  CMObjectClassNameRegistrySpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/26/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
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
        NSInteger newCount = [[registry valueForKey:@"classNameMappings"] count];
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
