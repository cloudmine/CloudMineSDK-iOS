//
//  CMDistance.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@interface CMDistance : NSObject

@property (strong, nonatomic, readonly) NSString * units;
@property (nonatomic, readonly) double distance;

- initWithDistance:(double)theDistance andUnits:(NSString *)theUnits;

@end
