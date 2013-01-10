//
//  CMObjectDecoderSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <YAJLiOS/YAJL.h>
#import "Kiwi.h"

#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"
#import "CMSerializable.h"
#import "NSString+UUID.h"
#import "CMGenericSerializableObject.h"
#import "CMCrossPlatformGenericSerializableObject.h"

SPEC_BEGIN(CMObjectDecoderSpec)

/**
 * Note: This test relies on the proper functioning of <tt>CMObjectEncoder</tt> to
 * generate the original dictionary representation of the object and to test
 * the symmetry of the encode/decode methods.
 */
describe(@"CMObjectDecoder", ^{
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
        NSDictionary *dictionary = [@"{ \"1234\": { \"__id__\": \"1234\", \"__class__\": \"map\", \"name\": \"foo\" } }" yajl_JSON];
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
        NSLog(@"TEST101: %@", originalObjectsDictionaryRepresentation);
        
        NSArray *decodedObjects = [CMObjectDecoder decodeObjects:originalObjectsDictionaryRepresentation];
        [[[decodedObjects should] have:1] items];
        
        [[[decodedObjects lastObject] valueForKey:@"dictionary"] isKindOfClass:[NSDictionary class]];
    });
});

SPEC_END
