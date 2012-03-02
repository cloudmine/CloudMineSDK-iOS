//
//  CMUserCredentials.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>
#import "CMUserAccountResult.h"

typedef void (^CMUserOperationCallback)(CMUserAccountResult resultCode);

/**
 * Representation of an end-user in CloudMine. This class manages session state (i.e. tokens and all that).
 */
@interface CMUser : NSObject <NSCoding>

/**
 * The user's identifier (i.e. email address).
 */
@property (atomic, strong) NSString *userId;

/**
 * The user's password.
 */
@property (atomic, strong) NSString *password;

/**
 * The user's login token, as assigned after a successful login attempt.
 * When setting this propertly, CMUser#password will be set to <tt>nil</tt> for security reasons.
 */
@property (atomic, strong) NSString *token;

/**
 * <tt>YES</tt> if the user is logged in and <tt>NO</tt> otherwise. Being logged in
 * is defined by having a session token set.
 *
 * @see CMUser#token
 */
@property (readonly) BOOL isLoggedIn;

/**
 * Initialize the user with an email address and password.
 */
- (id)initWithUserId:(NSString *)userId andPassword:(NSString *)password;

- (void)loginWithCallback:(CMUserOperationCallback)callback;
- (void)logoutWithCallback:(CMUserOperationCallback)callback;
- (void)changePasswordTo:(NSString *)newPassword callback:(CMUserOperationCallback)callback;
- (void)resetPasswordWithCallback:(CMUserOperationCallback)callback;

@end
