//
//  CMSortDescriptor.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@interface CMSortDescriptor : NSObject

- (id)initWithFieldsAndDirections:(NSString *)fieldsAndDirections, ... NS_REQUIRES_NIL_TERMINATION;

@end
