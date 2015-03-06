//
//  NSMutableData+RandomData.h
//  cloudmine-ios
//
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (RandomData)
+ (instancetype)randomDataWithLength:(NSUInteger)length;
@end
