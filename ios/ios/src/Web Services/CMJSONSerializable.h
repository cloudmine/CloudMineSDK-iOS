//
//  CMJSONSerializable.h
//  cloudmine-ios
//
//  Created by Marc Weil on 11/25/11.
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMJSONSerializable <NSObject, NSCoding>

@property (atomic, readonly) NSString *objectId;

@end
