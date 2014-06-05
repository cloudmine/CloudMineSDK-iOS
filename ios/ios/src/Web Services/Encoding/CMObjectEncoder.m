//
//  CMObjectEncoder.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectEncoder.h"
#import "CMSerializable.h"
#import "CMObjectSerialization.h"
#import "CMGeoPoint.h"
#import "CMDate.h"
#import "CMACL.h"
#import "CMCoding.h"

@interface CMObjectEncoder (Private)
- (NSArray *)encodeAllInList:(NSArray *)list;
- (NSDictionary *)encodeAllInDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)serializeContentsOfObject:(id)obj;
@end

@implementation CMObjectEncoder

#pragma mark - Kickoff methods

+ (NSDictionary *)encodeObjects:(id<NSFastEnumeration>)objects;
{
    NSMutableDictionary *topLevelObjectsDictionary = [NSMutableDictionary dictionary];
    for (id<NSObject,CMSerializable> object in objects) {
        if (![object conformsToProtocol:@protocol(CMSerializable)]) {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"All objects to be serialized to CloudMine must conform to CMSerializable"
                                   userInfo:@{@"object": object}]
             raise];
        }

        if (![object respondsToSelector:@selector(objectId)] || object.objectId == nil) {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"All objects must supply their own unique, non-nil object identifier"
                                   userInfo:@{@"object": object}]
             raise];
        }

        // Each top-level object gets its own encoder, and the result of each serialization is stored
        // at the key specified by the object.
        CMObjectEncoder *objectEncoder = [[CMObjectEncoder alloc] init];
        [object encodeWithCoder:objectEncoder];
        NSMutableDictionary *encodedRepresentation = [NSMutableDictionary dictionaryWithDictionary:objectEncoder.encodedRepresentation];
        [encodedRepresentation setObject:[[object class] className] forKey:CMInternalClassStorageKey];
        [topLevelObjectsDictionary setObject:encodedRepresentation forKey:object.objectId];
    }

    return topLevelObjectsDictionary;
}

- (NSDictionary *)encodeCMCoding:(id<CMCoding>)object;
{
    CMObjectEncoder *objectEncoder = [[CMObjectEncoder alloc] init];
    [object encodeWithCoder:objectEncoder];
    NSMutableDictionary *encodedRepresentation = [NSMutableDictionary dictionaryWithDictionary:objectEncoder.encodedRepresentation];
    
    NSString *className = nil;
    if ([[object class] respondsToSelector:@selector(className)]) {
        className = [[object class] className];
    } else {
        className = NSStringFromClass([object class]);
    }
    
    [encodedRepresentation setObject:className forKey:CMInternalClassStorageKey];
    return encodedRepresentation;
}

- (id)init;
{
    if (self = [super init]) {
        _encodedData = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Keyed archiving methods defined by NSCoder

- (BOOL)containsValueForKey:(NSString *)key;
{
    return ([_encodedData objectForKey:key] != nil);
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key;
{
    [_encodedData setObject:[NSNumber numberWithBool:boolv] forKey:key];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key;
{
    [_encodedData setObject:[NSNumber numberWithDouble:realv] forKey:key];
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key;
{
    [_encodedData setObject:[NSNumber numberWithFloat:realv] forKey:key];
}

- (void)encodeInt:(int)intv forKey:(NSString *)key;
{
    [_encodedData setObject:[NSNumber numberWithInt:intv] forKey:key];
}

- (void)encodeInteger:(NSInteger)intv forKey:(NSString *)key;
{
    [_encodedData setObject:[NSNumber numberWithInteger:intv] forKey:key];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key;
{
    [_encodedData setObject:[NSNumber numberWithInt:intv] forKey:key];
}

- (void)encodeObject:(id)objv forKey:(NSString *)key;
{
    [_encodedData setObject:[self serializeContentsOfObject:objv] forKey:key];
}

#pragma mark - Private encoding methods

- (NSArray *)encodeAllInList:(NSArray *)list;
{
    NSMutableArray *encodedArray = [NSMutableArray arrayWithCapacity:[list count]];
    for (id item in list) {
        [encodedArray addObject:[self serializeContentsOfObject:item]];
    }
    return encodedArray;
}

- (NSDictionary *)encodeAllInDictionary:(NSDictionary *)dictionary;
{
    NSMutableDictionary *encodedDictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionary count]];
    for (id key in dictionary) {
        [encodedDictionary setObject:[self serializeContentsOfObject:[dictionary objectForKey:key]] forKey:key];
    }
    [encodedDictionary setObject:CMInternalHashClassName forKey:CMInternalClassStorageKey]; // to differentiate between a custom object and a dictionary.
    return encodedDictionary;
}

- (id)serializeContentsOfObject:(id)objv;
{
    if (objv == NULL || [objv isKindOfClass:[NSNull class]]) {
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
    } else if ([objv isKindOfClass:[CMGeoPoint class]] || [objv isKindOfClass:[CMDate class]] || [objv isKindOfClass:[CMACL class]]) {
        CMObjectEncoder *newEncoder = [[CMObjectEncoder alloc] init];
        [objv encodeWithCoder:newEncoder];
        NSMutableDictionary *serializedRepresentation = [NSMutableDictionary dictionaryWithDictionary:newEncoder.encodedRepresentation];
        [serializedRepresentation setObject:[[objv class] className] forKey:CMInternalClassStorageKey];
        return serializedRepresentation;
    } else if ([objv isKindOfClass:[CMObject class]]) {
        return [CMObjectEncoder encodeObjects:@[objv]];
    } else if ([[objv class] conformsToProtocol:@protocol(CMCoding)]) {
        CMObjectEncoder *newEncoder = [[CMObjectEncoder alloc] init];
        NSDictionary *serializedRepresentation = [newEncoder encodeCMCoding:objv];
        return serializedRepresentation;
    } else {
        [[NSException exceptionWithName:@"CMInternalInconsistencyException"
                                 reason:@"You can only store simple values, dictionaries, and arrays in CMObject instance variables."
                               userInfo:nil]
         raise];

        return nil;
    }
}

#pragma mark - Required methods (metadata and base serialization methods)

- (BOOL)allowsKeyedCoding;
{
    return YES;
}

#pragma mark - Translation methods

- (NSDictionary *)encodedRepresentation;
{
    return [_encodedData copy];
}

#pragma mark - Unimplemented methods

- (id)decodeObject;
{
    [[NSException exceptionWithName:NSInvalidArgumentException
                             reason:@"Cannot call decode methods on an encoder"
                           userInfo:nil]
     raise];

    return nil;
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key;
{
    [[NSException exceptionWithName:NSInvalidArgumentException
                             reason:@"64-bit integers are not supported. Use 32-bit or a string instead."
                           userInfo:nil]
     raise];
}

@end
