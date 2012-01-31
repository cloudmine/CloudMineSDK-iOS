//
//  CMUserCredentials.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * Basic container class for a user's identifier and password.
 */
@interface CMUser : NSObject<NSCoding>

/**
 * The user's identifier (i.e. email address).
 */
@property (strong) NSString *userId;

/**
 * The user's password.
 */
@property (strong) NSString *password;

- (id)initWithUserId:(NSString *)userId andPassword:(NSString *)password;

@end
