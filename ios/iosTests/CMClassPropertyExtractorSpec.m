//
//  CMObjectSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMClassPropertyExtractor.h"

@interface CMSimpleObject : NSObject
@property (readonly) int someInt;
@property (readonly) float someFloat;
@property (readonly) BOOL someBool;
@property (readonly, weak) NSObject *someObject;
@property (readonly, weak) id someOtherObject;
@end
@implementation CMSimpleObject
@synthesize someInt, someFloat, someBool, someObject, someOtherObject;
@end

SPEC_BEGIN(CMClassPropertyExtractorSpec)

describe(@"CMClassPropertyExtractor", ^{
    it(@"should extract the types of an Objective-C object correctly", ^{
        NSArray *properties = [[CMClassPropertyExtractor propertiesForClass:[CMSimpleObject class]] allObjects];
        [[properties should] haveCountOf:5];
        [[properties should] containObjects:@"someInt", @"someFloat", @"someBool", @"someObject", @"someOtherObject", nil];
    });
});

SPEC_END
