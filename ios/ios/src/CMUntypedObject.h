//
//  CMUntypedObject.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMObject.h"

/**
 * This is a subclass of CMObject that has no type information. It is used when the framework is
 * unable to determine which class an object should be deserialized into. This could happen if
 * your application is creating objects through the REST API (or some other means) and not adding
 * `__class__` attributes. This class does not attempt to deserialize object fields; it just leaves
 * them as an accessible NSDictionary.
 */
@interface CMUntypedObject : CMObject

/**
 * This dictionary stores all the fields contained in this object.
 */
@property (strong, nonatomic) NSDictionary *fields;

- (id)initWithFields:(NSDictionary *)theFields objectId:(NSString *)objId;

@end
