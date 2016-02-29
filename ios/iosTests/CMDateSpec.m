//
//  CMDateSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/23/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMDate.h"

SPEC_BEGIN(CMDateSpec)

describe(@"CMDate", ^{
    
    it(@"should create a date object with no object id", ^{
        CMDate *date = [[CMDate alloc] init];
        [[ theValue([date conformsToProtocol:@protocol(CMSerializable)]) should] equal:@YES];
        [[date.objectId should] beNil];
    });
    
    it(@"should not equal a string", ^{
        CMDate *date = [[CMDate alloc] init];
        [[ theValue([date isEqual:@"Test"]) should] equal:@NO];
    });
    
    it(@"should initialize an object with the current date", ^{
        
        NSDate *real = [NSDate date];
        CMDate *date = [[CMDate alloc] init];
        
        [[date should] equal:real];
    });
    
    it(@"should create a date object with an internal date", ^{
        NSDate *dated = [NSDate dateWithTimeIntervalSince1970:0];
        CMDate *date = [[CMDate alloc] initWithDate:dated];
        [[date.date should] equal:dated];
    });
    
    it(@"should properly forward methods to NSDate", ^{
        NSDate *dated = [NSDate dateWithTimeIntervalSince1970:0];
        CMDate *earlier = [[CMDate alloc] initWithDate:dated];
        CMDate *later = [[CMDate alloc] init];
        NSDate *winner =  [earlier earlierDate:later];
        [[winner should] equal:earlier];
        [[[earlier forwardingTargetForSelector:@selector(init)] should] equal:earlier.date];
    });
    
    it(@"should have the same timeIntervalSinceReferenceDate as it's date", ^{
        CMDate *date = [[CMDate alloc] init];
        [[ theValue([date timeIntervalSinceReferenceDate]) should] equal: theValue([date.date timeIntervalSinceReferenceDate])];
    });
    
    it(@"should have the same timeIntervalSinceReferenceDate as NSDate", ^{
        [[ theValue([CMDate timeIntervalSinceReferenceDate]) should] equal:[NSDate timeIntervalSinceReferenceDate] withDelta:1.0];
    });
    
});

SPEC_END
