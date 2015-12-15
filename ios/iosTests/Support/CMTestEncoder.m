//
//  CMTestEncoder.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 4/19/14.
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//

#import "CMTestEncoder.h"

@implementation CMTestEncoderInt

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super initWithCoder:aDecoder]) ) {
        self.anInt = [aDecoder decodeIntegerForKey:@"anInt"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.anInt forKey:@"anInt"];
}

@end

@implementation CMTestEncoderInt32

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super initWithCoder:aDecoder]) ) {
        self.anInt = [aDecoder decodeInt32ForKey:@"anInt"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt32:_anInt forKey:@"anInt"];
}

@end

@implementation CMTestEncoderBool

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super initWithCoder:aDecoder]) ) {
        self.aBool = [aDecoder decodeBoolForKey:@"aBool"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_aBool forKey:@"aBool"];
}

@end

@implementation CMTestEncoderFloat

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super initWithCoder:aDecoder]) ) {
        self.aFloat = [aDecoder decodeFloatForKey:@"aFloat"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.aFloat forKey:@"aFloat"];
}

@end

@implementation CMTestEncoderUUID

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super initWithCoder:aDecoder]) ) {
        NSUInteger blockSize;
        const void* bytes = [aDecoder decodeBytesForKey:@"uuid" returnedLength:&blockSize];
        self.uuid = [[NSUUID alloc] initWithUUIDBytes:bytes];
        self.uuid = [[NSUUID alloc] initWithUUIDString:[aDecoder decodeObjectForKey:@"uuid"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    uuid_t uuid;
    [self.uuid getUUIDBytes:uuid];
    [aCoder encodeBytes:uuid length:16 forKey:@"uuid"];
}

@end

@implementation CMTestEncoderNSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super init]) ) {
        self.aString = [aDecoder decodeObjectForKey:@"aString"];
        self.anInt = [aDecoder decodeIntegerForKey:@"anInt"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.aString forKey:@"aString"];
    [aCoder encodeInteger:self.anInt forKey:@"anInt"];
}

@end

@implementation CMTestEncoderNSCodingParent

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super initWithCoder:aDecoder]) ) {
        self.something = [aDecoder decodeObjectForKey:@"something"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.something forKey:@"something"];
}

- (instancetype)initWithObjectId:(NSString *)theObjectId;
{
    if ( (self = [super initWithObjectId:theObjectId]) ) {
        self.something = [[CMTestEncoderNSCoding alloc] init];
        self.something.aString = @"Test!";
        self.something.anInt = 11;
    }
    return self;
}

@end


@implementation CMTestEncoderNSCodingDeeper

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if ( self = ([super init]) ) {
        self.aString = [aDecoder decodeObjectForKey:@"aString"];
        self.anInt = [aDecoder decodeIntegerForKey:@"anInt"];
        self.nestedCMObject = [aDecoder decodeObjectForKey:@"nestedCMObject"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.aString forKey:@"aString"];
    [aCoder encodeInteger:self.anInt forKey:@"anInt"];
    [aCoder encodeObject:self.nestedCMObject forKey:@"nestedCMObject"];
}

+ (NSString *)className;
{
    return @"TestEncoderDeeper";
}

@end
