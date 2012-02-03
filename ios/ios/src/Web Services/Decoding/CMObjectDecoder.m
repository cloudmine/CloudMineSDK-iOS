//
//  CMJSONDecoder.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectDecoder.h"
#import "CMSerializable.h"
#import "CMObjectSerialization.h"
#import "CMGeoPoint.h"
#import "CMDate.h"
#import "CMObjectClassNameRegistry.h"

@interface CMObjectDecoder (Private)
+ (Class)typeFromDictionaryRepresentation:(NSDictionary *)representation;
- (NSArray *)decodeAllInList:(NSArray *)list;
- (NSDictionary *)decodeAllInDictionary:(NSDictionary *)dictionary;
- (id)deserializeContentsOfObject:(id)objv;
@end

@implementation CMObjectDecoder

#pragma mark - Kickoff methods

+ (NSArray *)decodeObjects:(NSDictionary *)serializedObjects {
    NSMutableArray *decodedObjects = [NSMutableArray arrayWithCapacity:[serializedObjects count]];
    
    for (NSString *key in serializedObjects) {
        NSDictionary *objectRepresentation = [serializedObjects objectForKey:key];
        CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:objectRepresentation];
        id<CMSerializable> decodedObject = [[[CMObjectDecoder typeFromDictionaryRepresentation:objectRepresentation] alloc] initWithCoder:decoder];
        
        if (decodedObject) {
            [decodedObjects addObject:decodedObject];
        } else {
            NSLog(@"Failed to deserialize and inflate object with dictionary representation:\n%@", objectRepresentation);
        }
    }
    
    return decodedObjects;
}

- (id)initWithSerializedObjectRepresentation:(NSDictionary *)representation {
    if (self = [super init]) {
        _dictionaryRepresentation = [representation copy];
    }
    return self;
}

#pragma mark - Keyed archiving methods defined by NSCoder

- (BOOL)containsValueForKey:(NSString *)key {
    return ([_dictionaryRepresentation objectForKey:key] != nil);
}

- (BOOL)decodeBoolForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return NO;
    }
    return [[_dictionaryRepresentation valueForKey:key] boolValue];
}

- (double)decodeDoubleForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return (double)0.0;
    }
    return [[_dictionaryRepresentation valueForKey:key] doubleValue];
}

- (float)decodeFloatForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return 0.0f;
    }
    return [[_dictionaryRepresentation valueForKey:key] floatValue];
}

- (int)decodeIntForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return 0;
    }
    return [[_dictionaryRepresentation valueForKey:key] intValue];
}

- (NSInteger)decodeIntegerForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return (NSInteger)0;
    }
    return [[_dictionaryRepresentation valueForKey:key] integerValue];
}

- (int32_t)decodeInt32ForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return (int32_t)0;
    }
    return (int32_t)[[_dictionaryRepresentation valueForKey:key] intValue];

}

- (id)decodeObjectForKey:(NSString *)key {
    return [self deserializeContentsOfObject:[_dictionaryRepresentation objectForKey:key]];
}

#pragma mark - Private encoding methods

+ (Class)typeFromDictionaryRepresentation:(NSDictionary *)representation {
    NSString *className = [representation objectForKey:CMInternalTypeStorageKey];
    Class klass = nil;
    
    if ([className isEqualToString:CMInternalHashClassName]) {
        klass = [NSDictionary class];
    } else {
        // First try to look up a custom class name (i.e. a name given to a CMObject subclass by overriding +className).
        klass = [[CMObjectClassNameRegistry sharedInstance] classForName:className];
        
        // If it's still nil, assume the name is not custom but instead is actually just the name of the class.
        if (klass == nil) {
            klass = NSClassFromString(className);
        }
        
        // At this point we have no idea what the class is, so fail.
        NSAssert(klass, @"Class with name \"%@\" could not be loaded during remote object deserialization.", className);
    }
    
    return klass;
}

- (NSArray *)decodeAllInList:(NSArray *)list {
    NSMutableArray *decodedArray = [NSMutableArray arrayWithCapacity:[list count]];
    for (id item in list) {
        [decodedArray addObject:[self deserializeContentsOfObject:item]];
    }
    return decodedArray;
}

- (NSDictionary *)decodeAllInDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *decodedDictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionary count]];
    for (id key in dictionary) {
        [decodedDictionary setObject:[self deserializeContentsOfObject:[dictionary objectForKey:key]] forKey:key];
    }
    return decodedDictionary;
}

- (id)deserializeContentsOfObject:(id)objv {
    if ([objv isKindOfClass:[NSNull class]]) {
        return nil;
    } else if ([objv isKindOfClass:[NSString class]] || [objv isKindOfClass:[NSNumber class]]) {
        // Strings and numbers are natively handled and need no further decomposition.
        return objv;
    } else if ([objv isKindOfClass:[NSArray class]]) {
        return [self decodeAllInList:objv];
    } else if ([objv isKindOfClass:[NSDictionary class]]) {
        // For now we need to special-case CMGeoPoint and CMDate since we don't support nested objects other
        // than dictionaries at this point. Once that support is added we can simply use the CMObjectClassNameRegistry
        // to deserialize any class properly.
        
        if ([[objv objectForKey:CMInternalTypeStorageKey] isEqualToString:CMInternalHashClassName]) {
            return [self decodeAllInDictionary:objv];
        } else if ([[objv objectForKey:CMInternalTypeStorageKey] isEqualToString:CMGeoPointClassName]) {
            CMObjectDecoder *subObjectDecoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:objv];
            return [[CMGeoPoint alloc] initWithCoder:subObjectDecoder];
        } else if ([[objv objectForKey:CMInternalTypeStorageKey] isEqualToString:CMDateClassName]) {
            CMObjectDecoder *subObjectDecoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:objv];
            return [[CMDate alloc] initWithCoder:subObjectDecoder];
        }
    }
    
    [[NSException exceptionWithName:@"CMInternalInconsistencyException"
                             reason:@"Trying to deserialize a non-dictionary object is not supported." 
                           userInfo:nil] 
     raise];
    
    return nil;

        //TODO: Uncomment the lines below when server-side support for object relationships is done.
        
//        // A new decoder is needed as we are digging down further into a custom object.
//        CMObjectDecoder *subObjectDecoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:objv];
//        Class objectClass = [CMObjectDecoder typeFromDictionaryRepresentation:objv];
//        return [[objectClass alloc] initWithCoder:subObjectDecoder];
}

#pragma mark - Required methods (metadata and base serialization methods)

- (BOOL)allowsKeyedCoding {
    return YES;
}

#pragma mark - Unimplemented methods

- (void)encodeObject:(id)object {
    [[NSException exceptionWithName:NSInvalidArgumentException 
                             reason:@"Cannot call encode methods on an decoder" 
                           userInfo:nil] 
     raise];
}

- (int64_t)decodeInt64ForKey:(NSString *)key {
    [[NSException exceptionWithName:NSInvalidArgumentException 
                             reason:@"64-bit integers are not supported. Decode as 32-bit."
                           userInfo:nil] 
     raise];
    
    return (int64_t)0;
}

@end
