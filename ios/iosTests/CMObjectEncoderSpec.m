//
//  CMObjectEncoderSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMObjectEncoder.h"
#import "CMSerializable.h"
#import "NSString+UUID.h"
#import "CMGenericSerializableObject.h"
#import "CMCrossPlatformGenericSerializableObject.h"
#import "CMObjectSerialization.h"
#import "CMGeoPoint.h"
#import "CMDate.h"
#import "CMTestEncoder.h"

SPEC_BEGIN(CMObjectEncoderSpec)

describe(@"CMObjectEncoder", ^{
    
    it(@"should not be able to decode at all", ^{
         [[theBlock(^{ [[CMObjectEncoder new] decodeObject]; }) should] raiseWithName:NSInvalidArgumentException];
    });
    
    it(@"cannot encode 64 bit integers", ^{
        [[theBlock(^{ [[CMObjectEncoder new] encodeInt64:1 forKey:@"something"]; }) should] raiseWithName:NSInvalidArgumentException];
    });
    
    it(@"should allow key value pairing", ^{
        [[ theValue([[CMObjectEncoder new] allowsKeyedCoding]) should] equal:@YES];
    });
    
    it(@"should have nothing at first", ^{
        CMObjectEncoder *encoder = [CMObjectEncoder new];
        [[theValue([encoder containsValueForKey:@"something"]) should] equal:@NO];
    });
    
    it(@"should contain a value after encoding it", ^{
        CMObjectEncoder *encoder = [CMObjectEncoder new];
        [[theValue([encoder containsValueForKey:@"something"]) should] equal:@NO];
        [encoder encodeInt:10 forKey:@"int"];
        [[theValue([encoder containsValueForKey:@"int"]) should] equal:@YES];
    });
    
    it(@"should encode a single object correctly", ^{
        NSString *uuid = [NSString stringWithUUID];
        CMGenericSerializableObject *object = [[CMGenericSerializableObject alloc] initWithObjectId:uuid];
        [object fillPropertiesWithDefaults];
        [object.dictionary setValue:[NSNull null] forKey:@"testNull"];

        // Add a geo field.
        CMGeoPoint *geoPoint = [[CMGeoPoint alloc] initWithLatitude:14.1247 andLongitude:-74.199887];
        object.nestedObject = geoPoint;

        // Run the serialization.
        NSDictionary *dictionaryOfData = [CMObjectEncoder encodeObjects:[NSSet setWithObject:object]];

        // Check the integrity data.
        [dictionaryOfData shouldNotBeNil];
        [[[dictionaryOfData should] have:1] items];

        [[dictionaryOfData should] haveValueForKey:uuid];
        NSDictionary *theOnlyObject = [dictionaryOfData objectForKey:uuid];
        [[[theOnlyObject objectForKey:CMInternalObjectIdKey] should] equal:uuid];
        [[[theOnlyObject objectForKey:CMInternalClassStorageKey] should] equal:@"CMGenericSerializableObject"];
        [[[theOnlyObject objectForKey:@"string1"] should] equal:@"Hello World"];
        [[[theOnlyObject objectForKey:@"string2"] should] equal:@"Apple Macintosh"];
        [[[theOnlyObject objectForKey:@"simpleInt"] should] equal:theValue(42)];
        [[theOnlyObject objectForKey:@"arrayOfBooleans"] shouldNotBeNil];
        [[[[theOnlyObject objectForKey:@"arrayOfBooleans"] should] have:5] items];
        [[[theOnlyObject objectForKey:@"nestedObject"] should] beKindOfClass:[NSDictionary class]];
        [[[theOnlyObject objectForKey:@"date"] should] beKindOfClass:[NSDictionary class]];
        [[[theOnlyObject objectForKey:@"dictionary"] should] beKindOfClass:[NSDictionary class]];
        [[[[theOnlyObject objectForKey:@"dictionary"] valueForKey:@"testNull"] should] beKindOfClass:[NSNull class]];


        //TODO: Uncomment when server-side support for object relationships is done.

//        [[theOnestednlyObject objectForKey:@"nestedObject"] shouldNotBeNil];

//        NSDictionary *nestedObject = [theOnlyObject objectForKey:@"nestedObject"];
//        [[[nestedObject objectForKey:CMInternalObjectIdKey] should] equal:object.nestedObject.objectId];
//        [[[nestedObject objectForKey:CMInternalClassStorageKey] should] equal:@"CMGenericSerializableObject"];
//        [[[nestedObject objectForKey:@"string1"] should] equal:@"Nested 1"];
//        [[[nestedObject objectForKey:@"string2"] should] equal:@"Nested 2"];
//        [[[nestedObject objectForKey:@"simpleInt"] should] equal:theValue(999)];
//        [[[nestedObject objectForKey:@"arrayOfBooleans"] should] equal:[NSNull null]];
//        [[[nestedObject objectForKey:@"nestedObject"] should] equal:[NSNull null]];
    });

    it(@"should encode an object with a custom class name correctly", ^{
        NSString *uuid = [NSString stringWithUUID];
        CMCrossPlatformGenericSerializableObject *object = [[CMCrossPlatformGenericSerializableObject alloc] initWithObjectId:uuid];
        [object fillPropertiesWithDefaults];

        // Run the serialization.
        NSDictionary *dictionaryOfData = [CMObjectEncoder encodeObjects:[NSSet setWithObject:object]];

        // Check the integrity data.
        [dictionaryOfData shouldNotBeNil];
        [[[dictionaryOfData should] have:1] items];

        [[dictionaryOfData should] haveValueForKey:uuid];
        NSDictionary *theOnlyObject = [dictionaryOfData objectForKey:uuid];
        [[[theOnlyObject objectForKey:CMInternalClassStorageKey] should] equal:@"genericObject"];
    });
    
    it(@"should encode an Integer properly", ^{
        NSString *uuid = [NSString stringWithUUID];
        CMTestEncoderInt *test = [[CMTestEncoderInt alloc] initWithObjectId:uuid];
        test.anInt = 10;
        
        // Run the serialization.
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        [[result shouldNot] beNil];
        [[[result should] have:1] items];
        [[result should] haveValueForKey:uuid];
        NSDictionary *object = result[uuid];
        [[object[@"anInt"] should] equal:@10];
    });
    
    it(@"should encode a 32 bit integer properly", ^{
        NSString *uuid = [NSString stringWithUUID];
        CMTestEncoderInt32 *test = [[CMTestEncoderInt32 alloc] initWithObjectId:uuid];
        test.anInt = 10;
        
        // Run the serialization.
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        [[result shouldNot] beNil];
        [[[result should] have:1] items];
        [[result should] haveValueForKey:uuid];
        NSDictionary *object = result[uuid];
        [[object[@"anInt"] should] equal:@10];
    });
    
    it(@"should encode a BOOL properly", ^{
        NSString *uuid = [NSString stringWithUUID];
        CMTestEncoderBool *test = [[CMTestEncoderBool alloc] initWithObjectId:uuid];
        test.aBool = YES;
        
        // Run the serialization.
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        [[result shouldNot] beNil];
        [[[result should] have:1] items];
        [[result should] haveValueForKey:uuid];
        NSDictionary *object = result[uuid];
        [[object[@"aBool"] should] equal:@YES];
    });
    
    it(@"should encode a float properly", ^{
        NSString *uuid = [NSString stringWithUUID];
        CMTestEncoderFloat *test = [[CMTestEncoderFloat alloc] initWithObjectId:uuid];
        test.aFloat = 10.5;
        
        // Run the serialization.
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        [[result shouldNot] beNil];
        [[[result should] have:1] items];
        [[result should] haveValueForKey:uuid];
        NSDictionary *object = result[uuid];
        [[object[@"aFloat"] should] equal:@10.5];
    });
    
    it(@"should encode an NSDate into a CMDate", ^{
        CMObjectEncoder *encoder = [CMObjectEncoder new];
        [encoder encodeObject:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"date"];
        NSDictionary *encoded = encoder.encodedRepresentation;
        [[encoded should] haveCountOf:1];
        [[encoded[@"date"] shouldNot] beNil];
        NSDictionary *date = encoded[@"date"];
        [[date should] haveCountOf:2];
        [[date[CMInternalClassStorageKey] shouldNot] beNil];
        [[date[CMInternalClassStorageKey] should] equal:@"datetime"];
        [[date[@"timestamp"] shouldNot] beNil];
        [[date[@"timestamp"] should] equal:@0];
    });
    
    it(@"should encode a NSSet into an NSArray", ^{
        CMObjectEncoder *encoder = [CMObjectEncoder new];
        NSSet *set = [NSSet setWithArray:@[@0, @1, @4, @10, @2]];
        [encoder encodeObject:set forKey:@"set"];
        
        NSDictionary *encoded = encoder.encodedRepresentation;
        [[encoded should] haveCountOf:1];
        [[encoded[@"set"] shouldNot] beNil];
        NSArray *final = encoded[@"set"];
        [[final should] haveCountOf:5];
    });
    
    it(@"should encode a UUID", ^{
        NSString *uuid = [NSString stringWithUUID];
        CMTestEncoderUUID *test = [[CMTestEncoderUUID alloc] initWithObjectId:uuid];
        test.uuid = [[NSUUID alloc] initWithUUIDString:@"e621e1f8-c36c-495a-93fc-0c247a3e6e5f"];
        
        // Run the serialization.
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        [[result shouldNot] beNil];
        [[[result should] have:1] items];
        [[result should] haveValueForKey:uuid];
        NSDictionary *object = result[uuid];
        [[object[@"uuid"] should] equal:@"5iHh+MNsSVqT/Awkej5uXw=="];
    });
    
    it(@"should raise an exception when given a non-serializable object", ^{
        CMObjectEncoder *encoder = [CMObjectEncoder new];
        [[theBlock(^{ [encoder encodeObject:[NSObject new] forKey:@"object"]; }) should] raiseWithName:@"CMInternalInconsistencyException"];
    });
    
    it(@"should raise an exception when given a non-serializable object from class method", ^{
        [[theBlock(^{ [CMObjectEncoder encodeObjects:@[[NSObject new]]]; }) should] raiseWithName:NSInvalidArgumentException];
    });
    
    it(@"should raise an exception if the object has no ObjectId", ^{
        CMObject *randomObject = [[CMObject alloc] initWithObjectId:nil];
        [[theBlock(^{ [CMObjectEncoder encodeObjects:@[randomObject]]; }) should] raiseWithName:NSInvalidArgumentException];
    });
    
    it(@"should encode an object that adheres to NSCoding is encoded properly", ^{
        NSString *uuid = [NSString stringWithUUID];
        CMTestEncoderNSCodingParent *test = [[CMTestEncoderNSCodingParent alloc] initWithObjectId:uuid];
        
        // Run the serialization.
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        [[result shouldNot] beNil];
        [[[result should] have:1] items];
        [[result should] haveValueForKey:uuid];
        NSDictionary *object = result[uuid];
        [[object[@"something"] should] beKindOfClass:[NSDictionary class]];
        NSDictionary *something = object[@"something"];
        [[something[@"aString"] should] equal:@"Test!"];
        [[something[@"anInt"] should] equal:@11];
        [[something[@"__class__"] should] equal:@"CMTestEncoderNSCoding"];
    });
    
    it(@"should encode an object that adheres to NSCoding and has nested objects encodes properly", ^{
        NSString *uuid = [NSString stringWithUUID];
        NSString *uuid2 = [NSString stringWithUUID];
        CMTestEncoderNSCodingParent *test = [[CMTestEncoderNSCodingParent alloc] initWithObjectId:uuid];
        CMTestEncoderNSCodingDeeper *deeper = [[CMTestEncoderNSCodingDeeper alloc] init];
        deeper.aString = @"Testing!";
        deeper.anInt = 12;
        deeper.nestedCMObject = [[CMTestEncoderFloat alloc] initWithObjectId:uuid2];
        deeper.nestedCMObject.aFloat = 42.5;
        test.something = deeper;
        
        // Run the serialization.
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        [[result shouldNot] beNil];
        [[[result should] have:1] items];
        [[result should] haveValueForKey:uuid];
        NSDictionary *object = result[uuid];
        [[object[@"something"] should] beKindOfClass:[NSDictionary class]];
        NSDictionary *something = object[@"something"];
        [[something[@"aString"] should] equal:@"Testing!"];
        [[something[@"anInt"] should] equal:@12];
        [[something[@"nestedCMObject"] shouldNot] beNil];
        [[something[@"nestedCMObject"][uuid2] shouldNot] beNil];
        [[[something[@"nestedCMObject"] should] have:1] items];
        NSDictionary *deeperNested = something[@"nestedCMObject"][uuid2];
        [[deeperNested[@"aFloat"] should] equal:@42.5];
        [[deeperNested[@"__class__"] should] equal:@"CMTestEncoderFloat"];
    });
    
    
});

SPEC_END
