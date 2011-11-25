//
//  CMJSONEncoder.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMJSONEncoder.h"

@interface CMJSONEncoder (Private)
- (NSData *)jsonData;
@end

@implementation CMJSONEncoder

#pragma mark - Kickoff methods

- (NSData *)serializeObjects:(id<NSFastEnumeration>)objects {
    for (id<NSObject,NSCoding> object in objects) {
        if (![object conformsToProtocol:@protocol(NSCoding)]) {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"All objects to be serialized to JSON must conform to NSCoding"
                                   userInfo:nil] raise];
        }
        [object encodeWithCoder:self];
    }
    return [self jsonData];
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

- (void)encodeObject:(id<NSCoding>)objv forKey:(NSString *)key {
    CMJSONEncoder *newEncoder = [[[self class] alloc] init];
    [objv encodeWithCoder:newEncoder];
    [_encodedData setObject:newEncoder.encodedData forKey:key];
}

#pragma mark - Required methods (metadata and base serialization methods)

- (BOOL)allowsKeyedCoding {
    return YES;
}

#pragma mark - Translation methods

- (NSData *)jsonData {
    return [[_encodedData yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)encodedData {
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
