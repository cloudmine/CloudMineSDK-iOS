//
//  CMTools.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 10/24/13.
//  Copyright (c) 2013 CloudMine, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"CM DEBUG MODE: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

@interface CMTools : NSObject

+ (NSString *)urlEncode:(NSString *)string;

+ (NSString *)urlEncodeButLeaveQuery:(NSString *)string;

@end
