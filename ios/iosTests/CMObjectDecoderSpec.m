//
//  CMObjectDecoderSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"
#import "CMSerializable.h"
#import "NSString+UUID.h"
#import "CMGenericSerializableObject.h"
#import "CMCrossPlatformGenericSerializableObject.h"
#import "CMTestEncoder.h"
#import "CMUntypedObject.h"
#import "CMACL.h"

SPEC_BEGIN(CMObjectDecoderSpec)

/**
 * Note: This test relies on the proper functioning of <tt>CMObjectEncoder</tt> to
 * generate the original dictionary representation of the object and to test
 * the symmetry of the encode/decode methods.
 */
describe(@"CMObjectDecoder", ^{
    
    it(@"should not be able to encode", ^{
        [[theBlock(^{ [[CMObjectDecoder new] encodeObject:nil]; }) should] raiseWithName:NSInvalidArgumentException];
    });
    
    it(@"should decode a boolean to YES", ^{
        NSDictionary *encoded = @{@"aBool": @YES};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        BOOL result = [decoder decodeBoolForKey:@"aBool"];
        [[theValue(result) should] equal:@YES];
    });
    
    it(@"should decode a boolean to NO", ^{
        NSDictionary *encoded = @{@"aBool": @NO};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        BOOL result = [decoder decodeBoolForKey:@"aBool"];
        [[theValue(result) should] equal:@NO];
    });
    
    it(@"should decode nothing to NO", ^{
        NSDictionary *encoded = @{};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        BOOL result = [decoder decodeBoolForKey:@"aBool"];
        [[theValue(result) should] equal:@NO];
    });
    
    it(@"should decode a NSNull to NO", ^{
        NSDictionary *encoded = @{@"aBool": [NSNull null]};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        BOOL result = [decoder decodeBoolForKey:@"aBool"];
        [[theValue(result) should] equal:@NO];
    });
    
    it(@"should decode a double properly", ^{
        NSDictionary *encoded = @{@"aDouble": @(10.5)};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        double result = [decoder decodeDoubleForKey:@"aDouble"];
        [[theValue(result) should] equal:@(10.5)];
    });
    
    it(@"should decode a non-existant double to 0.0", ^{
        NSDictionary *encoded = @{};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        double result = [decoder decodeDoubleForKey:@"aDouble"];
        [[theValue(result) should] equal:@(0)];
    });
    
    it(@"should decode a NSNull to 0.0", ^{
        NSDictionary *encoded = @{@"aDouble": [NSNull null]};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        BOOL result = [decoder decodeDoubleForKey:@"aDouble"];
        [[theValue(result) should] equal:@0];
    });
    
    it(@"should decode a float properly", ^{
        NSDictionary *encoded = @{@"aFloat": @(10.5)};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        CGFloat result = [decoder decodeFloatForKey:@"aFloat"];
        [[theValue(result) should] equal:@(10.5)];
    });
    
    it(@"should decode a non-existant float to 0.0", ^{
        NSDictionary *encoded = @{};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        CGFloat result = [decoder decodeFloatForKey:@"aFloat"];
        [[theValue(result) should] equal:@(0)];
    });
    
    it(@"should decode a NSNull to 0.0", ^{
        NSDictionary *encoded = @{@"aFloat": [NSNull null]};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        CGFloat result = [decoder decodeFloatForKey:@"aFloat"];
        [[theValue(result) should] equal:@0];
    });
    
    it(@"should decode an int properly", ^{
        NSDictionary *encoded = @{@"anInt": @(11)};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        int result = [decoder decodeIntForKey:@"anInt"];
        [[theValue(result) should] equal:@(11)];
    });
    
    it(@"should decode a non-existant int to 0", ^{
        NSDictionary *encoded = @{};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        int result = [decoder decodeIntForKey:@"anInt"];
        [[theValue(result) should] equal:@(0)];
    });
    
    it(@"should decode a NSNull to 0", ^{
        NSDictionary *encoded = @{@"anInt": [NSNull null]};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        int result = [decoder decodeIntForKey:@"anInt"];
        [[theValue(result) should] equal:@0];
    });
    
    it(@"should decode an integer properly", ^{
        NSDictionary *encoded = @{@"anInteger": @(11)};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        NSInteger result = [decoder decodeIntegerForKey:@"anInteger"];
        [[theValue(result) should] equal:@(11)];
    });
    
    it(@"should decode a non-existant integer to 0", ^{
        NSDictionary *encoded = @{};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        NSInteger result = [decoder decodeIntegerForKey:@"anInteger"];
        [[theValue(result) should] equal:@(0)];
    });
    
    it(@"should decode a NSNull to 0", ^{
        NSDictionary *encoded = @{@"anInteger": [NSNull null]};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        NSInteger result = [decoder decodeIntegerForKey:@"anInteger"];
        [[theValue(result) should] equal:@0];
    });
    
    it(@"should decode a 32bit integer properly", ^{
        NSDictionary *encoded = @{@"integer32": @(11)};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        int32_t result = [decoder decodeInt32ForKey:@"integer32"];
        [[theValue(result) should] equal:@(11)];
    });
    
    it(@"should decode a non-existant 32bit integer to 0", ^{
        NSDictionary *encoded = @{};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        int32_t result = [decoder decodeInt32ForKey:@"integer32"];
        [[theValue(result) should] equal:@(0)];
    });
    
    it(@"should decode a NSNull to 0", ^{
        NSDictionary *encoded = @{@"integer32": [NSNull null]};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        int32_t result = [decoder decodeInt32ForKey:@"integer32"];
        [[theValue(result) should] equal:@0];
    });
    
    it(@"should not be able to decode a 64 bit integer", ^{
        NSDictionary *encoded = @{@"integer64": @(11)};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        [[theBlock(^{ [decoder decodeInt64ForKey:@"integer64"]; }) should] raiseWithName:NSInvalidArgumentException];
    });
    
    it(@"should decode a UUID", ^{
        NSDictionary *encoded = @{@"uuid": @"5iHh+MNsSVqT/Awkej5uXw=="};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        
        NSUInteger size;
        const uint8_t *bytes = [decoder decodeBytesForKey:@"uuid" returnedLength:&size];
        NSUUID *created = [[NSUUID alloc] initWithUUIDBytes:bytes];
        [[created should] equal:[[NSUUID alloc] initWithUUIDString:@"e621e1f8-c36c-495a-93fc-0c247a3e6e5f"]];
    });
    
    it(@"should not be able to decode a random NSObject", ^{
        NSDictionary *encoded = @{@"object": [NSObject new]};
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:encoded];
        [[theBlock(^{ [decoder decodeObjectForKey:@"object"]; }) should] raiseWithName:@"CMInternalInconsistencyException"];
    });
    
    it(@"should decode a random dictionary into a CMUntypedObject", ^{
        NSDictionary *encoded = @{@100101: @{@"firstName": @"name", @"lastName": @"aName"}};
        NSArray *decoded = [CMObjectDecoder decodeObjects:encoded];
        CMUntypedObject *object = [decoded lastObject];
        [[object shouldNot] beNil];
        [[NSStringFromClass([object class]) should] equal:@"CMUntypedObject"];
        [[object.fields should] haveCountOf:3];
        [[object.fields[@"firstName"] should] equal:@"name"];
        [[object.fields[@"lastName"] should] equal:@"aName"];
    });
    
    it(@"should decode a CMUser which has the type 'user'", ^{
        NSDictionary *encoded = @{@"theId": @{@"firstName": @"name", @"lastName": @"aName", @"__type__" : @"user"}};
        NSArray *decoded = [CMObjectDecoder decodeObjects:encoded];
        CMUser *aUser = [decoded lastObject];
        [[NSStringFromClass([aUser class]) should] equal:@"CMUser"];
    });
    
    it(@"should decode a single object correctly", ^{
        // Create the original object and serialize it. This will serve as the input for the real test.
        CMGenericSerializableObject *originalObject = [[CMGenericSerializableObject alloc] init];
        [originalObject fillPropertiesWithDefaults];
        [originalObject.dictionary setValue:[NSNull null] forKey:@"testingNull"];
        
        NSDictionary *originalObjectDictionaryRepresentation = [CMObjectEncoder encodeObjects:[NSSet setWithObject:originalObject]];

        // Create everything needed to decode this representation now.
        NSArray *decodedObjects = [CMObjectDecoder decodeObjects:originalObjectDictionaryRepresentation];

        // Test the symmetry.
        [[[decodedObjects should] have:1] items];
        [[[decodedObjects objectAtIndex:0] should] equal:originalObject];
    });

    it(@"should decode multiple objects correctly", ^{
        NSMutableArray *originalObjects = [NSMutableArray arrayWithCapacity:5];
        for (int i=0; i<5; i++) {
            CMGenericSerializableObject *obj = [[CMGenericSerializableObject alloc] init];
            [obj fillPropertiesWithDefaults];
            [originalObjects addObject:obj];
        }

        NSDictionary *originalObjectsDictionaryRepresentation = [CMObjectEncoder encodeObjects:originalObjects];
        NSArray *decodedObjects = [CMObjectDecoder decodeObjects:originalObjectsDictionaryRepresentation];

        [[[decodedObjects should] have:5] items];
        [decodedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [[obj should] equal:[originalObjects objectAtIndex:idx]];
        }];
    });

    it(@"should decode a single object with a custom class name correctly", ^{
        // Create the original object and serialize it. This will serve as the input for the real test.
        CMCrossPlatformGenericSerializableObject *originalObject = [[CMCrossPlatformGenericSerializableObject alloc] init];
        [originalObject fillPropertiesWithDefaults];
        NSDictionary *originalObjectDictionaryRepresentation = [CMObjectEncoder encodeObjects:[NSSet setWithObject:originalObject]];

        // Create everything needed to decode this representation now.
        NSArray *decodedObjects = [CMObjectDecoder decodeObjects:originalObjectDictionaryRepresentation];

        // Test the symmetry.
        [[[decodedObjects should] have:1] items];
        [[[decodedObjects objectAtIndex:0] should] beKindOfClass:[CMCrossPlatformGenericSerializableObject class]];
        [[[decodedObjects objectAtIndex:0] should] equal:originalObject];
    });

    it(@"should NOT be able to deserialize a dictionary when it's at the top-level", ^{
        
        NSDictionary *dictionary = @{@"1234": @{@"__id__": @"1234", @"__class__" : @"map", @"name": @"foo"}};
        [[theBlock(^{
            [CMObjectDecoder decodeObjects:dictionary];
        }) should] raiseWithName:@"CMInternalInconsistencyException"];
    });

    it(@"should decode multiple objects properly when some of them don't have __id__ fields but do have __class__ fields", ^{
        NSMutableArray *originalObjects = [NSMutableArray arrayWithCapacity:5];
        for (int i=0; i<5; i++) {
            CMGenericSerializableObject *obj = [[CMGenericSerializableObject alloc] init];
            [obj fillPropertiesWithDefaults];
            [originalObjects addObject:obj];
        }

        NSDictionary *originalObjectsDictionaryRepresentation = [CMObjectEncoder encodeObjects:originalObjects];

        // Now strip out the __id__ field from some of the objects.
        NSMutableDictionary *objectsDictRepForTesting = [NSMutableDictionary dictionary];
        __block int count = 0;
        [originalObjectsDictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
            NSMutableDictionary *mutObj = [obj mutableCopy];
            if (count < 2) {
                [mutObj removeObjectForKey:@"__id__"];
            }
            [objectsDictRepForTesting setObject:mutObj forKey:key];
            count += 1;
        }];

        // Decoding shouldn't crash, of course.
        NSArray *decodedObjects = [CMObjectDecoder decodeObjects:objectsDictRepForTesting];
        [[[decodedObjects should] have:5] items];

        // Now let's make sure that the objectId property has been filled for all the objects.
        for (id<CMSerializable> obj in decodedObjects) {
            [[[obj objectId] shouldNot] beNil];
            [[[originalObjectsDictionaryRepresentation objectForKey:obj.objectId] shouldNot] beNil];
        }
    });
    
    it(@"should decode internal NSDictionary's with no __class__ attribute properly", ^{
        CMGenericSerializableObject *object = [[CMGenericSerializableObject alloc] init];
        [object fillPropertiesWithDefaults];
        [object.dictionary setValue:@"Testing" forKey:@"test"];
        
        NSDictionary *originalObjectsDictionaryRepresentation = [CMObjectEncoder encodeObjects:@[object]];
        
        [[[originalObjectsDictionaryRepresentation valueForKey:object.objectId] valueForKey:@"dictionary"] removeObjectForKey:@"__class__"];
        
        NSArray *decodedObjects = [CMObjectDecoder decodeObjects:originalObjectsDictionaryRepresentation];
        [[[decodedObjects should] have:1] items];
        
        [[[decodedObjects lastObject] valueForKey:@"dictionary"] isKindOfClass:[NSDictionary class]];
    });
    
    it(@"should decode NSCoded dictionaries properly", ^{
        ///
        /// This works fine and has been tested
        ///
        NSString *uuid = [NSString stringWithUUID];
        CMTestEncoderNSCodingParent *test = [[CMTestEncoderNSCodingParent alloc] initWithObjectId:uuid];
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        
        ///
        /// This is being tested
        ///
        NSArray *decoded = [CMObjectDecoder decodeObjects:result];
        [[[decoded should] have:1] items];
        CMTestEncoderNSCodingParent *final = [decoded firstObject];
        [[final should] beKindOfClass:[CMTestEncoderNSCodingParent class]];
        [[final.something shouldNot] beNil];
        [[final.something should] beKindOfClass:[CMTestEncoderNSCoding class]];
        CMTestEncoderNSCoding *coding = final.something;
        [[coding.aString should] equal:@"Test!"];
        [[theValue(coding.anInt) should] equal:@11];
    });
    
    it(@"should decode an object that adheres to NSCoding and has nested objects properly", ^{
        NSString *uuid = [NSString stringWithUUID];
        NSString *uuid2 = [NSString stringWithUUID];
        CMTestEncoderNSCodingParent *test = [[CMTestEncoderNSCodingParent alloc] initWithObjectId:uuid];
        CMTestEncoderNSCodingDeeper *deeper = [[CMTestEncoderNSCodingDeeper alloc] init];
        deeper.aString = @"Testing!";
        deeper.anInt = 12;
        deeper.nestedCMObject = [[CMTestEncoderFloat alloc] initWithObjectId:uuid2];
        deeper.nestedCMObject.aFloat = 42.5;
        test.something = deeper;
        NSDictionary *result = [CMObjectEncoder encodeObjects:@[test]];
        
        ///
        /// This is being tested
        ///
        NSArray *decoded = [CMObjectDecoder decodeObjects:result];
        [[[decoded should] have:1] items];
        CMTestEncoderNSCodingParent *final = [decoded firstObject];
        [[final should] beKindOfClass:[CMTestEncoderNSCodingParent class]];
        [[final.something shouldNot] beNil];
        [[final.something should] beKindOfClass:[CMTestEncoderNSCodingDeeper class]];
        CMTestEncoderNSCodingDeeper *coding = (CMTestEncoderNSCodingDeeper *)final.something;
        [[coding.aString should] equal:@"Testing!"];
        [[theValue(coding.anInt) should] equal:@12];
        [[coding.nestedCMObject shouldNot] beNil];
        [[coding.nestedCMObject should] beKindOfClass:[CMTestEncoderFloat class]];
        CMTestEncoderFloat *last = coding.nestedCMObject;
        [[theValue(last.aFloat) should] equal:@42.5];
        
    });
});

SPEC_END
