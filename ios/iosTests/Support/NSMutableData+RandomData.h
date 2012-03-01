//
//  NSMutableData+RandomData.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@interface NSMutableData (RandomData)
+ (id)randomDataWithLength:(NSUInteger)length;
@end
