//
//  CMJSONEncoder.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMJSONEncoder.h"
#import "CMJSONSerializable.h"

@interface CMJSONEncoder (Private)
- (NSData *)jsonData;
- (NSArray *)encodeAllInList:(NSArray *)list;
- (NSDictionary *)encodeAllInDictionary:(NSDictionary *)dictionary;
@end

@implementation CMJSONEncoder

#pragma mark - Kickoff methods

+ (NSData *)serializeObjects:(id<NSFastEnumeration>)objects {
    NSMutableDictionary *topLevelObjectsDictionary = [NSMutableDictionary dictionary];
    for (id<NSObject,CMJSONSerializable> object in objects) {
        if (![object conformsToProtocol:@protocol(CMJSONSerializable)]) {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"All objects to be serialized to JSON must conform to CMJSONSerializable"
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
        CMJSONEncoder *objectEncoder = [[self alloc] init];
        [object encodeWithCoder:objectEncoder];
        [topLevelObjectsDictionary setObject:objectEncoder.jsonRepresentation forKey:object.objectId];
    }
    
    return [[topLevelObjectsDictionary yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
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
    if ([objv isKindOfClass:[NSString class]] || [objv isKindOfClass:[NSNumber class]]) {
        // Strings and numbers are natively handled in JSON and need no further decomposition.
        [_encodedData setObject:objv forKey:key];
    } else if ([objv isKindOfClass:[NSArray class]]) {
        [_encodedData setObject:[self encodeAllInList:objv] forKey:key];
    } else if ([objv isKindOfClass:[NSSet class]]) {
        [_encodedData setObject:[self encodeAllInList:[objv allObjects]] forKey:key];
    } else if ([objv isKindOfClass:[NSDictionary class]]) {
        [_encodedData setObject:[self encodeAllInDictionary:objv] forKey:key];
    } else {
        // A new encoder is needed as we are digging down further into a custom object
        // and we don't want to flatten the data in all the sub-objects.
        CMJSONEncoder *newEncoder = [[[self class] alloc] init];
        [objv encodeWithCoder:newEncoder];
        [_encodedData setObject:newEncoder.jsonRepresentation forKey:key];
    }
}

#pragma mark - Private encoding methods

- (NSArray *)encodeAllInList:(NSArray *)list {
    
}

- (NSDictionary *)encodeAllInDictionary:(NSDictionary *)dictionary {
    
}

#pragma mark - Required methods (metadata and base serialization methods)

- (BOOL)allowsKeyedCoding {
    return YES;
}

#pragma mark - Translation methods

- (NSData *)jsonData {
    return [[_encodedData yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)jsonRepresentation {
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
                             reason:@"JSON does not support 64-bit integers. Use 32-bit or a string instead." 
                           userInfo:nil] 
     raise];
}

@end
