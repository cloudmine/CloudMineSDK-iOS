//
//  CMJSONDecoder.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObjectDecoder.h"

@implementation CMObjectDecoder

#pragma mark - Kickoff methods

+ (NSArray *)decodeObjects:(NSDictionary *)serializedObjects {
    NSMutableArray *decodedObjects = [NSMutableArray arrayWithCapacity:[serializedObjects count]];
    
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
    
}

#pragma mark - Private encoding methods

- (Class)typeFromDictionaryRepresentation:(NSDictionary *)representation {
    NSString *className = [representation objectForKey:@"__type__"];
    Class klass = nil;
    
    if ([className isEqualToString:@"map"]) {
        klass = [NSDictionary class];
    } else {
        klass = NSClassFromString(className);
        NSAssert(klass, @"Class with name \"%@\" could not be loaded during remote object deserialization.", className);
    }
    
    return klass;
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
