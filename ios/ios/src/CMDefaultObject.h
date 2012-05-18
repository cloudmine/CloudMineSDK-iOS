//
//  CMDefaultObject.h
//  cloudmine-ios
//
//  Created by Derek Mansen on 5/16/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMObject.h"

/**
 * This is the default subclass of CMObject, used when the framework is unable to determine which
 * class an object should be deserialized into. This could happen if your application is creating
 * objects through the REST API or other means and not adding __class__ attributes. This class does
 * not attempt to deserialize object fields; it just leaves them as an accessible NSDictionary.
 */
@interface CMDefaultObject : CMObject

/**
 * This dictionary stores all the fields contained in this object.
 */
@property (strong, nonatomic) NSDictionary *fields;

- (id)initWithFields:(NSDictionary *)theFields objectId:(NSString *)objId;

@end
