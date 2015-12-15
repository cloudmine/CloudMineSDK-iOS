//
//  CMGenericSerializableObject.h
//  cloudmine-iosTests
//
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"
@class CMDate;

@interface CMGenericSerializableObject : CMObject

// All the properties we will try to serialize in the tests.
@property (nonatomic, strong) NSString *string1;
@property (nonatomic, strong) NSString *string2;
@property (nonatomic, assign) int simpleInt;
@property (nonatomic, strong) NSArray *arrayOfBooleans;
@property (nonatomic, strong) id<CMSerializable> nestedObject;
@property (nonatomic, strong) CMDate *date;
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) NSMutableDictionary *dictionary;

- (void)fillPropertiesWithDefaults;

@end
