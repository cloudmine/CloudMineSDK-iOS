//
//  CMDateSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/23/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMDate.h"
#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"
#import "CMObject.h"

@interface CMDateTestWrapper : CMObject
- (instancetype)initWithDate:(CMDate *)date;
@property (nonatomic) CMDate *date;
@end

@implementation CMDateTestWrapper

- (instancetype)initWithDate:(CMDate *)date
{
    self = [super init];
    if (nil == self) return nil;

    self.date = date;

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil == self) return nil;

    self.date = [aDecoder decodeObjectForKey:@"date"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.date forKey:@"date"];
}

@end

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

    it(@"should serialize and deserialize correclty with NSCoder", ^{
        CMDate *date = [CMDate new];

        NSData *dateData = [NSKeyedArchiver archivedDataWithRootObject:date];
        CMDate *codedDate = [NSKeyedUnarchiver unarchiveObjectWithData:dateData];

        [[date should] equal:codedDate];
    });

    it(@"should serialize and deserialize correctly with NSCoder when wrapped in a CMObject", ^{
        CMDateTestWrapper *wrapper = [[CMDateTestWrapper alloc] initWithDate:[CMDate new]];

        NSData *wrapperData = [NSKeyedArchiver archivedDataWithRootObject:wrapper];
        CMDateTestWrapper *codedWrapper = [NSKeyedUnarchiver unarchiveObjectWithData:wrapperData];

        [[wrapper.date should] equal:codedWrapper.date];
    });

    it(@"should serialize and deserialize correctly with CMCoder", ^{
        CMDateTestWrapper *wrapper = [[CMDateTestWrapper alloc] initWithDate:[CMDate new]];

        NSDictionary *encodedWrapper = [CMObjectEncoder encodeObjects:@[wrapper]];
        CMDateTestWrapper *codedWrapper = [CMObjectDecoder decodeObjects:encodedWrapper].firstObject;

        [[wrapper.date should] equal:codedWrapper.date];
    });
    
});

SPEC_END
