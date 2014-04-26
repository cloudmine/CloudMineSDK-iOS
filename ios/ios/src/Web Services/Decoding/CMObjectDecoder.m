//
//  CMObjectDecoder.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectDecoder.h"
#import "CMUntypedObject.h"
#import "CMSerializable.h"
#import "CMObjectSerialization.h"
#import "CMGeoPoint.h"
#import "CMACL.h"
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

    for (id key in serializedObjects) {
        NSMutableDictionary *objectRepresentation = [[serializedObjects objectForKey:key] mutableCopy];

        Class klass = [CMObjectDecoder typeFromDictionaryRepresentation:objectRepresentation];

        id stringifiedKey = key;
        if (![stringifiedKey isKindOfClass:[NSString class]]) {
            stringifiedKey = [stringifiedKey stringValue];
        }
        
        // Let's be nice if __id__ wasn't specified in the object and help it out a bit.
        if ([objectRepresentation objectForKey:CMInternalObjectIdKey] == nil) {
            [objectRepresentation setObject:stringifiedKey forKey:CMInternalObjectIdKey];
        }

        id<CMSerializable> decodedObject = nil;
        if (klass == [CMUntypedObject class]) {
            decodedObject = [[CMUntypedObject alloc] initWithFields:objectRepresentation objectId:stringifiedKey];
        } else {
            CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:objectRepresentation];
            decodedObject = [[klass alloc] initWithCoder:decoder];
        }

        if (decodedObject) {
            if(![decodedObject isKindOfClass:[CMObject class]] && ![decodedObject isKindOfClass:[CMUser class]]) {
                [[NSException exceptionWithName:@"CMInternalInconsistencyException" reason:[NSString stringWithFormat:@"Can only deserialize top-level objects that inherit from CMObject. Got %@.", NSStringFromClass([decodedObject class])] userInfo:nil] raise];

                return nil;
            }

            // Add it to the final array of inflated objects.
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

- (id)decodeNSCoding:(NSDictionary *)object;
{
    CMObjectDecoder *decoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:object];
    Class klass = [CMObjectDecoder typeFromDictionaryRepresentation:object];
    id decodedObject = [[klass alloc] initWithCoder:decoder];
    return decodedObject;
}

#pragma mark - Keyed archiving methods defined by NSCoder

- (BOOL)containsValueForKey:(NSString *)key {
    return ([_dictionaryRepresentation objectForKey:key] != nil);
}

- (BOOL)decodeBoolForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return NO;
    }

    id val = [_dictionaryRepresentation valueForKey:key];
    if (val != nil && val != [NSNull null]) {
        return [[_dictionaryRepresentation valueForKey:key] boolValue];
    }
    return NO;
}

- (double)decodeDoubleForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return (double)0.0;
    }

    id val = [_dictionaryRepresentation valueForKey:key];
    if (val != nil && val != [NSNull null]) {
        return [[_dictionaryRepresentation valueForKey:key] doubleValue];
    }
    return (double)0.0;
}

- (float)decodeFloatForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return 0.0f;
    }

    id val = [_dictionaryRepresentation valueForKey:key];
    if (val != nil && val != [NSNull null]) {
        return [[_dictionaryRepresentation valueForKey:key] floatValue];
    }
    return 0.0f;
}

- (int)decodeIntForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return 0;
    }

    id val = [_dictionaryRepresentation valueForKey:key];
    if (val != nil && val != [NSNull null]) {
        return [[_dictionaryRepresentation valueForKey:key] intValue];
    }
    return 0;
}

- (NSInteger)decodeIntegerForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return (NSInteger)0;
    }

    id val = [_dictionaryRepresentation valueForKey:key];
    if (val != nil && val != [NSNull null]) {
        return [[_dictionaryRepresentation valueForKey:key] integerValue];
    }
    return 0;
}

- (int32_t)decodeInt32ForKey:(NSString *)key {
    if (![self containsValueForKey:key]) {
        return (int32_t)0;
    }

    id val = [_dictionaryRepresentation valueForKey:key];
    if (val != nil && val != [NSNull null]) {
        return [[_dictionaryRepresentation valueForKey:key] intValue];
    }
    return (int32_t)0;
}

- (id)decodeObjectForKey:(NSString *)key {
    return [self deserializeContentsOfObject:[_dictionaryRepresentation objectForKey:key]];
}

#pragma mark - Private encoding methods

+ (Class)typeFromDictionaryRepresentation:(NSDictionary *)representation {
    NSString *className = [representation objectForKey:CMInternalClassStorageKey];
    NSString *typeName = [representation objectForKey:CMInternalTypeStorageKey];
    Class klass = nil;

    if ([className isEqualToString:CMInternalHashClassName]) {
        klass = [NSDictionary class];
    } else if ([typeName isEqualToString:@"user"] && !className) {
        klass = [CMUser class];
    } else {
        // First try to look up a custom class name (i.e. a name given to a CMObject subclass by overriding +className).
        klass = [[CMObjectClassNameRegistry sharedInstance] classForName:className];

        // If it's still nil, assume the name is not custom but instead is actually just the name of the class.
        if (klass == nil) {
            klass = NSClassFromString(className);
        }

        // At this point we have no idea what the class is, so default to CMUntypedObject.
        if (klass == nil) {
            klass = [CMUntypedObject class];
        }
    }

    return klass;
}

- (NSArray *)decodeAllInList:(NSArray *)list {
    NSMutableArray *decodedArray = [NSMutableArray arrayWithCapacity:[list count]];
    for (id item in list) {
        [decodedArray addObject:[self nullIfNil:[self deserializeContentsOfObject:item]]];
    }
    return decodedArray;
}

- (NSDictionary *)decodeAllInDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *decodedDictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionary count]];
    for (id key in dictionary) {
        if (![CMInternalKeys containsObject:key]) {
            [decodedDictionary setObject:[self nullIfNil:[self deserializeContentsOfObject:[dictionary objectForKey:key]]] forKey:key];
        }
    }
    return decodedDictionary;
}

- (id)nullIfNil:(id)nilOrObject {
    return nilOrObject == nil ? [NSNull null] : nilOrObject;
}

- (id)deserializeContentsOfObject:(id)objv {
    if (!objv || [objv isKindOfClass:[NSNull class]]) {
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
        ///
        /// First thing, see if we can deserialzie the object into a CMObject
        ///
        @try {
            NSArray *result = [CMObjectDecoder decodeObjects:objv];
            return result[0];
        }
        @catch (NSException *exception) {
            ///
            /// Apparently NOT a CMObject subclass
            ///
        }
        
        if ( ([objv objectForKey:CMInternalClassStorageKey] == nil &&
              [objv objectForKey:CMInternalTypeStorageKey] == nil) ||
             [[objv objectForKey:CMInternalClassStorageKey] isEqualToString:CMInternalHashClassName] ) {
            
            return [self decodeAllInDictionary:objv];
        } else {
            CMObjectDecoder *subObjectDecoder = [[CMObjectDecoder alloc] initWithSerializedObjectRepresentation:objv];
            if ([[objv objectForKey:CMInternalTypeStorageKey] isEqualToString:CMGeoPointClassName]) {
                // Note that this uses CMInternalTypeStorageKey instead of CMInternalClassStorageKey on purpose
                // since the CM backend treats these objects as special unicorns (i.e. it has to know to geoindex them).
                return [[CMGeoPoint alloc] initWithCoder:subObjectDecoder];
            } else if ([[objv objectForKey:CMInternalTypeStorageKey] isEqualToString:CMACLTypeName]) {
                return [[CMACL alloc] initWithCoder:subObjectDecoder];
            } else if ([[objv objectForKey:CMInternalClassStorageKey] isEqualToString:CMDateClassName]) {
                return [[CMDate alloc] initWithCoder:subObjectDecoder];
            } else if (objv[CMInternalClassStorageKey] != nil) {
                return [self decodeNSCoding:objv];
            }
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
