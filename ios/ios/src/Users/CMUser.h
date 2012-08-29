//
//  CMUserCredentials.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import "CMSerializable.h"
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
 * The block callback for any user account operation that involves fetching one or more user profiles. The block returns <tt>void</tt>
 * and takes an <tt>NSArray</tt> containing all the deserialized <tt>CMUser</tt> (or subclass) instances as well as a dictionary of error messages
 * the server sent back. The second parameter will always be an empty dictionary except when using CMUser#userWithIdentifier:callback:, in which case
 * that will be the place where the "not found" error is recorded.
 */
typedef void (^CMUserFetchCallback)(NSArray *users, NSDictionary *errors);

/**
 * Representation of an end-user in CloudMine. This class manages session state (i.e. tokens and all that).
 *
 * <strong>Subclassing Notes</strong>
 * You can subclass <tt>CMUser</tt> to add your own user profile fields, if you'd like. <tt>CMUser</tt> conforms to <tt>CMSerializable</tt>, so you should implement
 * <tt>encodeWithCoder:</tt> and <tt>initWithCoder:</tt> in the same way as you would for a <tt>CMObject</tt> subclass. Be sure to call super's implementation
 * from both of those methods! Your custom fields will be pushed to the server when you first call CMUser#createAccountWithCallback: or CMUser#createAccountAndLoginWithCallback:.
 * Upon subsequent logins, the custom fields will be updated with those stored on CloudMine.
 */
@interface CMUser : NSObject <CMSerializable>

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
 * <tt>YES</tt> when the user's account and profile have been created server-side. If <tt>NO</tt>, it means the user exists only locally in your app.
 */
@property (readonly) BOOL isCreatedRemotely;

/**
 * The object is dirty if any changes have been made locally that have not yet been persisted to the server.
 */
@property (readonly) BOOL isDirty;

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
 * of the session token. In addition, all your custom properties (if you are using a custom subclass of <tt>CMUser</tt>) will be populated for you using key-value coding.
 * All these properties will be set <strong>before</strong> the callback block is invoked.
 *
 * <strong>Important</strong>
 * This method will cause the user's profile fields (i.e. any custom fields you have defined on your CMUser subclass) to be synced with the server state.
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
 * CMUser#createAccountAndLoginWithCallback: is a convenience method that creates and logs the user in at the same time.
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

/**
 * Saves this user's profile. If you call this before the user's account has been created server-side, this method is the same as CMUser#createAccountWithCallback.
 * If the account already exists, the profile will be updated server-side to reflect the state of this object.
 *
 * <strong>Important implementation note</strong>
 * If this user is not logged in, they must first be logged in before a save can be completed. The library will automatically do that for you if the user is logged out.
 * However, this has the effect of ignoring any server-side changes that may have occured since you last synchronized the state of the user's profile data. If you need
 * to synchronize state with the server before modifying the user's profile, you need to first login using CMUser#loginWithCallback: (which will sync the state of the profile)
 * and <em>then</em> modify the user profile as you wish. After that, calling this method will simply save.
 *
 * @param callback The block that will be called on completion of the operation.
 */
- (void)save:(CMUserOperationCallback)callback;

/**
 * Asynchronously fetch all the users of this app. This will download the profiles of all the users of your app, and is useful for displaying
 * lists of people to share with or running analytics on your users yourself. On completion, the <tt>callback</tt> block will be called with an array
 * of <tt>CMUser</tt> objects (or your custom subclass, if applicable) as well as a dictionary of errors.
 *
 * @param callback The block that will be called on completion of the operation.
 */
+ (void)allUsersWithCallback:(CMUserFetchCallback)callback;

/**
 * Asynchronously search all profiles of users of this app for matching fields. This will download the profiles of all matching users of your app, and is useful for displaying
 * and filtering lists of people to share with or running analytics on your users yourself. On completion, the <tt>callback</tt> block will be called with an array
 * of <tt>CMUser</tt> objects (or your custom subclass, if applicable) as well as a dictionary of errors.
 *
 * @param query The search query to run against all user profiles. This is the same syntax as defined at https://cloudmine.me/developer_zone#ref/query_syntax and used by <tt>CMStore</tt>'s search methods.
 * @param callback The block that will be called on completion of the operation.
 */
+ (void)searchUsers:(NSString *)query callback:(CMUserFetchCallback)callback;

/**
 * Asynchronously fetch a single user profile object from CloudMine given its object id. You can access this via CMUser#objectId.
 *
 * @param identifier The objectId of the user profile to fetch.
 * @param callback The block that will be called on completion of the operation.
 */
+ (void)userWithIdentifier:(NSString *)identifier callback:(CMUserFetchCallback)callback;

@end
