//
//  CMObjectEncoder.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectEncoder.h"
#import "CMSerializable.h"
#import "CMObjectSerialization.h"
#import "CMGeoPoint.h"
#import "CMDate.h"

@interface CMObjectEncoder (Private)
- (NSArray *)encodeAllInList:(NSArray *)list;
- (NSDictionary *)encodeAllInDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)serializeContentsOfObject:(id)obj;
@end

@implementation CMObjectEncoder

#pragma mark - Kickoff methods

+ (NSDictionary *)encodeObjects:(id<NSFastEnumeration>)objects {
    NSMutableDictionary *topLevelObjectsDictionary = [NSMutableDictionary dictionary];
    for (id<NSObject,CMSerializable> object in objects) {
        if (![object conformsToProtocol:@protocol(CMSerializable)]) {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"All objects to be serialized to CloudMine must conform to CMSerializable"
                                   userInfo:[NSDictionary dictionaryWithObject:object forKey:@"object"]]
             raise];
        }
        
        if (![object respondsToSelector:@selector(objectId)] || object.objectId == nil) {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"All objects must supply their own unique, non-nil object identifier"
                                   userInfo:[NSDictionary dictionaryWithObject:object forKey:@"object"]] 
             raise];
        }
        
        // Each top-level object gets its own encoder, and the result of each serialization is stored
        // at the key specified by the object.
        CMObjectEncoder *objectEncoder = [[CMObjectEncoder alloc] init];
        [object encodeWithCoder:objectEncoder];
        NSMutableDictionary *encodedRepresentation = [NSMutableDictionary dictionaryWithDictionary:objectEncoder.encodedRepresentation];
        [encodedRepresentation setObject:[[object class] className] forKey:CMInternalTypeStorageKey];
        [topLevelObjectsDictionary setObject:encodedRepresentation forKey:object.objectId];
    }
    
    return topLevelObjectsDictionary;
}

- (id)init {
    if (self = [super init]) {
        _encodedData = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Keyed archiving methods defined by NSCoder

- (BOOL)containsValueForKey:(NSString *)key {
    return ([_encodedData objectForKey:key] != nil);
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key {
    [_encodedData setObject:[NSNumber numberWithBool:boolv] forKey:key];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key {
    [_encodedData setObject:[NSNumber numberWithDouble:realv] forKey:key];
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key {
    [_encodedData setObject:[NSNumber numberWithFloat:realv] forKey:key];
}

- (void)encodeInt:(int)intv forKey:(NSString *)key {
    [_encodedData setObject:[NSNumber numberWithInt:intv] forKey:key];
}

- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key {
    [_encodedData setObject:[NSNumber numberWithInteger:intv] forKey:key];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key {
    [_encodedData setObject:[NSNumber numberWithInt:intv] forKey:key];
}

- (void)encodeObject:(id)objv forKey:(NSString *)key {
    [_encodedData setObject:[self serializeContentsOfObject:objv] forKey:key];
}

#pragma mark - Private encoding methods

- (NSArray *)encodeAllInList:(NSArray *)list {
    NSMutableArray *encodedArray = [NSMutableArray arrayWithCapacity:[list count]];
    for (id item in list) {
        [encodedArray addObject:[self serializeContentsOfObject:item]];
    }
    return encodedArray;
}

- (NSDictionary *)encodeAllInDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *encodedDictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionary count]];
    for (id key in dictionary) {
        [encodedDictionary setObject:[self serializeContentsOfObject:[dictionary objectForKey:key]] forKey:key];
    }
    [encodedDictionary setObject:CMInternalHashClassName forKey:CMInternalTypeStorageKey]; // to differentiate between a custom object and a dictionary.
    return encodedDictionary;
}

- (id)serializeContentsOfObject:(id)objv {
    if (objv == nil) {
        return [NSNull null];
    } else if ([objv isKindOfClass:[NSString class]] || [objv isKindOfClass:[NSNumber class]]) {
        // Strings and numbers are natively handled and need no further decomposition.
        return objv;
    } else if ([objv isKindOfClass:[NSDate class]] && ![objv isKindOfClass:[CMDate class]]) {
        // We can't serialize NSDates directly. They need to be converted first into a CMDate.
        return [self serializeContentsOfObject:[[CMDate alloc] initWithDate:objv]];
    } else if ([objv isKindOfClass:[NSArray class]]) {
        return [self encodeAllInList:objv];
    } else if ([objv isKindOfClass:[NSSet class]]) {
        return [self encodeAllInList:[objv allObjects]];
    } else if ([objv isKindOfClass:[NSDictionary class]]) {
        return [self encodeAllInDictionary:objv];
    } else if ([objv isKindOfClass:[CMGeoPoint class]] || [objv isKindOfClass:[CMDate class]]) {
        CMObjectEncoder *newEncoder = [[CMObjectEncoder alloc] init];
        [objv encodeWithCoder:newEncoder];
        NSMutableDictionary *serializedRepresentation = [NSMutableDictionary dictionaryWithDictionary:newEncoder.encodedRepresentation];
        [serializedRepresentation setObject:[[objv class] className] forKey:CMInternalTypeStorageKey];
        return serializedRepresentation;
    } else {
        [[NSException exceptionWithName:@"CMInternalInconsistencyException"
                                 reason:@"You can only store simple values, dictionaries, and arrays in CMObject instance variables." 
                               userInfo:nil] 
         raise];
        
        return nil;
        
//TODO: When server-side support is implemented for object references, re-enable all this stuff.

//        NSAssert([objv conformsToProtocol:@protocol(CMSerializable)],
//                 @"Trying to serialize unknown object %@ (must be collection, scalar, or conform to CMSerializable)", 
//                  objv);
//        
//        // A new encoder is needed as we are digging down further into a custom object
//        // and we don't want to flatten the data in all the sub-objects.
//        CMObjectEncoder *newEncoder = [[CMObjectEncoder alloc] init];
//        [objv encodeWithCoder:newEncoder];
//        
//        // Must encode the type of this object for decoding purposes.
//        NSMutableDictionary *serializedRepresentation = [NSMutableDictionary dictionaryWithDictionary:newEncoder.encodedRepresentation];
//        [serializedRepresentation setObject:[[objv class] className] forKey:CMInternalTypeStorageKey];
//        return serializedRepresentation;
    }
}

#pragma mark - Required methods (metadata and base serialization methods)

- (BOOL)allowsKeyedCoding {
    return YES;
}

#pragma mark - Translation methods

- (NSDictionary *)encodedRepresentation {
    return [_encodedData copy];
}

#pragma mark - Unimplemented methods

- (id)decodeObject {
    [[NSException exceptionWithName:NSInvalidArgumentException 
                             reason:@"Cannot call decode methods on an encoder" 
                           userInfo:nil] 
     raise];
    
    return nil;
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key {
    [[NSException exceptionWithName:NSInvalidArgumentException 
                             reason:@"64-bit integers are not supported. Use 32-bit or a string instead." 
                           userInfo:nil] 
     raise];
}

@end
