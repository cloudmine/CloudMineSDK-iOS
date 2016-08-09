//
//  CMSortDescriptor.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CMSortAscending;
extern NSString * const CMSortDescending;
#define CMSortDefault [NSNull null]

@interface CMSortDescriptor : NSObject

+ (instancetype)emptyDescriptor;

- (instancetype)initWithFieldsAndDirections:(NSString *)fieldsAndDirections, ...  NS_REQUIRES_NIL_TERMINATION;

- (nullable NSString *)directionOfField:(NSString *)fieldName;
- (NSUInteger)count;

- (void)sortByField:(NSString *)fieldName;
- (void)sortByField:(id)fieldName direction:(nullable id)direction;
- (void)stopSortingByField:(NSString *)fieldName;

- (NSString *)stringRepresentation;


@end

NS_ASSUME_NONNULL_END
