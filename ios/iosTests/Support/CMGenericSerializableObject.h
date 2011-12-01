//
//  CMGenericSerializableObject.h
//  cloudmine-iosTests
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMSerializable.h"

@interface CMGenericSerializableObject : NSObject <CMSerializable> {
    // The magical object id required by the CMSerializable protocol.
    NSString *_objectId;
}

// All the properties we will try to serialize in the tests.
@property (nonatomic, strong) NSString *string1;
@property (nonatomic, strong) NSString *string2;
@property (nonatomic, assign) int simpleInt;
@property (nonatomic, strong) NSArray *arrayOfBooleans;
@property (nonatomic, strong) CMGenericSerializableObject *nestedObject;

- (id)initWithObjectId:(NSString *)theObjectId;
- (void)fillPropertiesWithDefaults;

@end
