//
//  CMSortDescriptor.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

extern NSString * const CMSortAscending;
extern NSString * const CMSortDescending;
#define CMSortDefault [NSNull null]

@interface CMSortDescriptor : NSObject

+ (id)emptyDescriptor;

- (id)initWithFieldsAndDirections:(NSString *)fieldsAndDirections, ...  NS_REQUIRES_NIL_TERMINATION;

- (NSString *)directionOfField:(NSString *)fieldName;
- (NSUInteger)count;

- (void)sortByField:(NSString *)fieldName;
- (void)sortByField:(id)fieldName direction:(id)direction;
- (void)stopSortingByField:(NSString *)fieldName;

- (NSString *)stringRepresentation;

@end
