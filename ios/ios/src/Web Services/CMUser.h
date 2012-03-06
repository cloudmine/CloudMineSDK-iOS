//
//  CMUserCredentials.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import <Foundation/Foundation.h>
#import "CMUserAccountResult.h"

/**
 * The block callback for all user account and session operations that take place on an instance of <tt>CMUser</tt>.
 * The block returns <tt>void</tt> and takes a <tt>CMUserAccountResult</tt> code representing the reuslt of the operation,
 * as well as an array of messages the server sent back. These messages will more often than not be errors.
 *
 * Use the convenience functions <tt>CMUserAccountOperationSuccessful</tt> and <tt>CMUserAccountOperationFailed</tt>
 * to help you see if <tt>resultCode</tt> represents success or failure.
 */
typedef void (^CMUserOperationCallback)(CMUserAccountResult resultCode, NSArray *messages);

/**
 * Representation of an end-user in CloudMine. This class manages session state (i.e. tokens and all that).
 */
@interface CMUser : NSObject <NSCoding>

/**
 * The user's identifier (i.e. email address).
 */
@property (atomic, strong) NSString *userId;

/**
 * The user's plaintext password.
 */
@property (atomic, strong) NSString *password;

/**
 * The user's session token, as assigned after a successful login operation.
 * When setting this property, CMUser#password will be set to <tt>nil</tt> for security reasons.
 */
@property (atomic, strong) NSString *token;

/**
 * The date and time at which the session token is no longer valid.
 */
@property (atomic, strong) NSDate *tokenExpiration;

/**
 * <tt>YES</tt> if the user is logged in and <tt>NO</tt> otherwise. Being logged in
 * is defined by having a session token set and having a token expiration date in the future.
 *
 * @see CMUser#token
 * @see CMUser#tokenExpiration
 */
@property (readonly) BOOL isLoggedIn;

/**
 * Initialize the user with an email address and password.
 */
- (id)initWithUserId:(NSString *)userId andPassword:(NSString *)password;

/**
 * Asynchronously login the user and create a new session. On completion, the <tt>callback</tt> block will be called with
 * the result of the operation and any messages returned by the server contained in an array. See the CloudMine
 * documentation online for the possible contents of this array.
 *
 * Upon successful login, the CMUser#token property will be set to the user's new session token and the CMUser#password field
 * will be cleared for security reasons. The CMUser#tokenExpiration property will also be set with the expiration date and time
 * of the session token. These properties will be set <strong>before</strong> the callback block is invoked.
 *
 * Possible result codes:
 * - <tt>CMUserAccountLoginSucceeded</tt>
 * - <tt>CMUserAccountLoginFailedIncorrectCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see isLoggedIn
 * @see https://cloudmine.me/developer_zone#ref/account_login
 */
- (void)loginWithCallback:(CMUserOperationCallback)callback;

/**
 * Asynchronously logout the user and clear their session and session token. On completion, the <tt>callback</tt> block will be called with
 * the result of the operation and any messages returned by the server contained in an array. See the CloudMine
 * documentation online for the possible contents of this array.
 *
 * Upon successful logout, the CMUser#token and CMUser#tokenExpiration properties will be set to <tt>nil</tt>. This will
 * occur <strong>before</strong> the callback block is invoked.
 *
 * Possible result codes:
 * - <tt>CMUserAccountLogoutSucceeded</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see isLoggedIn
 * @see https://cloudmine.me/developer_zone#ref/account_logout
 */
- (void)logoutWithCallback:(CMUserOperationCallback)callback;

/**
 * Asynchronously create a new account for the user on CloudMine. This must be done once for each user before they can login.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * Note that this method simply creates the user account; it does not log the user in.
 * @see createAccountAndLoginWithCallback: for a convenience method that creates and logs the user in at the same time.
 *
 * Possible result codes:
 * - <tt>CMUserAccountCreateSucceeded</tt>
 * - <tt>CMUserAccountCreateFailedInvalidRequest</tt>
 * - <tt>CMUserAccountCreateFailedDuplicateAccount</tt>
 *
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see https://cloudmine.me/developer_zone#ref/account_create
 */
- (void)createAccountWithCallback:(CMUserOperationCallback)callback;

/**
 * A convenient method to create an account for the user if it doesn't already exist, and then log the user in if
 * the account was successfully created or already existed. On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * Possible result codes:
 * - <tt>CMUserAccountLoginSucceeded</tt>
 * - <tt>CMUserAccountLoginFailedIncorrectCredentials</tt> (if the account already exists and the supplied credentials are incorrect)
 *
 * @param callback The block that will be called on completion of the operation.
 */
- (void)createAccountAndLoginWithCallback:(CMUserOperationCallback)callback;

/**
 * Asynchronously change the password for this user. For security purposes, you must have the user enter his or her
 * old password and new password in order to perform this operation. This operation will succeed regardless of whether
 * the user's <tt>CMUser</tt> instance is logged in or not.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * @see resetForgottenPasswordWithCallback: instead if if the user has forgotten his or her password
 *
 * Possible result codes:
 * - <tt>CMUserAccountPasswordChangeSucceeded</tt>
 * - <tt>CMUserAccountPasswordChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param newPassword The new password to use.
 * @param oldPassword The user's old password.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see https://cloudmine.me/developer_zone#ref/password_change
 */
- (void)changePasswordTo:(NSString *)newPassword from:(NSString *)oldPassword callback:(CMUserOperationCallback)callback;

/**
 * Asynchronously reset the password for this user. This method is used to reset a user's password if
 * he or she forgot it. This method of course does not require the user to be logged in in order to function.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * This method causes an email to be sent to the user with a link that allows them to reset their password from their browser.
 * Upon creating a new password, the user will be able to login with it via your app immediately.
 *
 * Possible result codes:
 * - <tt>CMUserAccountPasswordResetEmailSent</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 * @see https://cloudmine.me/developer_zone#ref/password_reset
 */
- (void)resetForgottenPasswordWithCallback:(CMUserOperationCallback)callback;

@end
