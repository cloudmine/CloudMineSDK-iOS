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
#import "CMSocialLoginViewController.h"
#import "CMPaymentResponse.h"

@class CMCardPayment, CMUserResponse, ACAccount;

/** Social network identifier for Facebook */
extern NSString * const CMSocialNetworkFacebook;

/** Social network identifier for Twitter */
extern NSString * const CMSocialNetworkTwitter;

/** Social network identifier for Foursquare */
extern NSString * const CMSocialNetworkFoursquare;

/** Social network identifier for Instagream */
extern NSString * const CMSocialNetworkInstagram;

/** Social network identifier for Tumblr */
extern NSString * const CMSocialNetworkTumblr;

/** Social network identifier for Dropbox */
extern NSString * const CMSocialNetworkDropbox;

/** Social network identifier for Fitbit */
extern NSString * const CMSocialNetworkFitbit;

/** Social network identifier for GitHub */
extern NSString * const CMSocialNetworkGithub;

/** Social network identifier for LinkedIn */
extern NSString * const CMSocialNetworkLinkedin;

/** Social network identifier for Meetup.com */
extern NSString * const CMSocialNetworkMeetup;

/** Social network identifier for Runkeeper */
extern NSString * const CMSocialNetworkRunkeeper;

/** Social network identifier for Whithings */
extern NSString * const CMSocialNetworkWhithings;

/** Social network identifier for Wordpress.com */
extern NSString * const CMSocialNetworkWordpress;

/** Social network identifier for Yammer */
extern NSString * const CMSocialNetworkYammer;

/** Social network identifier for Singly */
extern NSString * const CMSocialNetworkSingly;

/** Social network identifier for Google */
extern NSString * const CMSocialNetworkGoogle;

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
 *
 * <strong>DEPRECATED:</strong> Now use <tt>email</tt>. This will be removed at a future date.
 *
 * <strong>Note:</strong> This variable now maps directly to email, and will be removed at a futre date. Please use email instead.
 */
@property (atomic, strong) NSString *userId __attribute__((deprecated));

/**
 * The user's email (the new User ID).
 */
@property (atomic, strong) NSString *email;

/**
 * The user's plaintext password.
 */
@property (atomic, strong) NSString *password;

/**
 * The user's plaintext password
 */
@property (atomic, strong) NSString *username;

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
 * The social services the user has linked their profile to.
 */
@property (atomic, strong) NSArray *services;

/**
 * Initialize the user with an email address and password.
 *
 * <strong>DEPRECATED:</strong> Now use <tt>initWithEmail:andPassword:</tt> instead.
 */
- (instancetype)initWithUserId:(NSString *)userId andPassword:(NSString *)password __attribute__((deprecated));

/**
 * Initialize the user with an email address and password.
 */
- (instancetype)initWithEmail:(NSString *)theEmail andPassword:(NSString *)thePassword;

/**
 * Initialize the user with a Username and password.
 */
- (instancetype)initWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword;

/**
 * Initialize the user with an email, username, and password.
 *
 * <strong>DEPRECATED:</strong> Now use <tt>initWithEmail:andUsername:andPassword:</tt> instead.
 */
- (instancetype)initWithUserId:(NSString *)theUserId andUsername:(NSString *)theUsername andPassword:(NSString *)thePassword __attribute__((deprecated));

/**
 * Initialize the user with an email, username, and password.
 */
- (instancetype)initWithEmail:(NSString *)theEmail andUsername:(NSString *)theUsername andPassword:(NSString *)thePassword;

/**
 * Logs in to social account given the Access Token associated with it. This can either be used to
 * link the account, or create a new account. If the user is currently logged (@see isLoggedIn), it will
 * send the session_token, and link the user. If the user is not logged in it will create the user.
 * This method is most useful for OAuth 2 social networks, such as Facebook.
 *
 * @param network The CMSocialNetwork to login to.
 * @param accessToken The token that identifies the user. This will be checked server side.
 * @param descriptors An array of descriptors for the request.
 * @param callback The block that will be called on completion of the operation.
 */
- (void)loginWithSocialNetwork:(NSString *)network
                  accessToken:(NSString *)accessToken
                   descriptors:(NSArray *)descriptors
                      callback:(void (^) (CMUserResponse *response) )callback;

/**
 * Logs in to social account given the Token and Secret associated with it. This can either be used to
 * link the account, or create a new account. If the user is currently logged (@see isLoggedIn), it will
 * send the session_token, and link the user. If the user is not logged in it will create the user.
 * This method is most useful for OAuth 1 social networks, such as Twitter.
 *
 * @param network The CMSocialNetwork to login to.
 * @param oauthToken The token that identifies the user. This will be checked server side.
 * @param oauthTokenSecret The token secret that identifies the user. This will be checked server side.
 * @param descriptors An array of descriptors for the request.
 * @param callback The block that will be called on completion of the operation.
 */
- (void)loginWithSocialNetwork:(NSString *)network
                    oauthToken:(NSString *)oauthToken
              oauthTokenSecret:(NSString *)oauthTokenSecret
                   descriptors:(NSArray *)descriptors
                      callback:(void (^) (CMUserResponse *response) )callback;

/**
 * Logs in to social account given a dictionary of credentials. This can either be used to
 * link the account, or create a new account. If the user is currently logged (@see isLoggedIn), it will
 * send the session_token, and link the user. If the user is not logged in it will create the user.
 * This method will simply serialize the credentials and send it to the server. Developers should
 * use loginWithSocialNetwork:oauthToken:oauthTokenSecret:callback: or loginWithSocialNetwork:access_token:callback:
 * instead for convenience.
 *
 * @param network The CMSocialNetwork to login to.
 * @param credentials The set of credentials for the user. This will be checked server side.
 * @param descriptors An array of descriptors for the request.
 * @param callback The block that will be called on completion of the operation.
 */
- (void)loginWithSocialNetwork:(NSString *)network
                   credentials:(NSDictionary *)credentials
                   descriptors:(NSArray *)descriptors
                      callback:(void (^) (CMUserResponse *response) )callback;

/**
 * Creates a new user with an access_token for the user. This will create a new user, which
 * can be accessed from response.user. This method is most useful for OAuth 2 social networks,
 * such as Facebook.
 *
 * @param network The CMSocialNetwork to login to.
 * @param accessToken The token that identifies the user. This will be checked server side.
 * @param descriptors An array of descriptors for the request.
 * @param callback The block that will be called on completion of the operation.
 */
+ (void)userWithSocialNetwork:(NSString *)network
                 accessToken:(NSString *)accessToken
                  descriptors:(NSArray *)descriptors
                     callback:(void (^) (CMUserResponse *response) )callback;

/**
 * Logs in to social account given the Token and Secret associated with it. This can either be used to
 * link the account, or create a new account. If the user is currently logged (@see isLoggedIn), it will
 * send the session_token, and link the user. If the user is not logged in it will create the user.
 * This method is most useful for OAuth 1 social networks, such as Twitter.
 *
 * @param network The CMSocialNetwork to login to.
 * @param oauthToken The token that identifies the user. This will be checked server side.
 * @param oauthTokenSecret The token secret that identifies the user. This will be checked server side.
 * @param descriptors An array of descriptors for the request.
 * @param callback The block that will be called on completion of the operation.
 */
+ (void)userWithSocialNetwork:(NSString *)network
                   oauthToken:(NSString *)oauthToken
             oauthTokenSecret:(NSString *)oauthTokenSecret
                  descriptors:(NSArray *)descriptors
                     callback:(void (^) (CMUserResponse *response) )callback;

/**
 * Creates a new user with a dictionary of credentials. This will create a new user, which
 * can be accessed from response.user. This method will simply serialize the credentials and
 * send it to the server. Developers should use loginWithSocialNetwork:oauthToken:oauthTokenSecret:callback:
 * or loginWithSocialNetwork:access_token:callback: instead for convenience.
 *
 * @param network The CMSocialNetwork to login to.
 * @param credentials The set of credentials for the user. This will be checked server side.
 * @param descriptors An array of descriptors for the request.
 * @param callback The block that will be called on completion of the operation.
 */
+ (void)userWithSocialNetwork:(NSString *)network
                  credentials:(NSDictionary *)credentials
                  descriptors:(NSArray *)descriptors
                     callback:(void (^) (CMUserResponse *response) )callback;


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
 * @see https://cloudmine.me/docs/ios/reference#users_login
 */
- (void)loginWithCallback:(CMUserOperationCallback)callback;

/**
 * Login with social networking sites through Singly.  Calls a UIWebView for authentication, which loads the authentication page of the
 * social network you specify.
 *
 * If you call this method and the user is logged in already, it will link the logged in user with the social network account. If the user
 * is not logged in, this call will create a new user.
 * 
 * Upon successful login, the CMUser#token property will be set to the user's new session token The CMUser#tokenExpiration property will also be set with the expiration date and time
 * of the session token. In addition, all your custom properties (if you are using a custom subclass of <tt>CMUser</tt>) will be populated for you using key-value coding.
 * All these properties will be set <strong>before</strong> the callback block is invoked.
 *
 * Possible result codes:
 * - <tt>CMUserAccountLoginSucceeded</tt>
 * - <tt>CMUserAccountLoginFailedIncorrectCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 *
 * @param service The social service to be logged into
 * @param viewController the current view controller in use when this method is called
 * @param params Any extra parameters you want passed in to the authentication request. This dictionary is parsed where each key value pair becomes "&key=value". We do not encode the URL after this, so any encoding will need to be done by the creator. This is a good place to put scope, for example: @{@"scope" : @"gist,repo"}
 * @param callback The block that will be called on completion of the operation.
 * @see https://cloudmine.me/docs/api#users_social
 */
- (CMSocialLoginViewController *)loginWithSocialNetwork:(NSString *)service
                                         viewController:(UIViewController *)viewController
                                                 params:(NSDictionary *)params
                                               callback:(CMUserOperationCallback)callback;


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
 * @see https://cloudmine.me/docs/ios/reference#users_logout
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
 * @see https://cloudmine.me/docs/ios/reference#users_create
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
 * @see https://cloudmine.me/docs/ios/reference#users_pass_change
 */
- (void)changePasswordTo:(NSString *)newPassword from:(NSString *)oldPassword callback:(CMUserOperationCallback)callback;

/**
 *
 * <strong>DEPRECATED:</strong> This method is now deprecated. Use <tt>changeEmailTo:password:callback:</tt> instead.
 *
 * Asynchronously change the User ID for this user. For security purposes, you must have the user enter his or her
 * current password in order to perform this operation. The user does not need to be logged in to change this property. If this method
 * is successful then the user is automatically logged in again to get their new session token. If it is not successful, the user is not logged out.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * @see userId for notes on how User ID is now used.
 *
 * Possible result codes:
 * - <tt>CMUserAccountUserIdChangeSucceeded</tt>
 * - <tt>CMUserAccountCredentialChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateUserId</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 * - <tt>CMUserAccountUnknownResult</tt>
 *
 * @param newUserId The new User ID for this user. It needs to be in the form of an email address. If you don't want to use an email
    then you should <tt>username</tt>
 * @param currentPassword The current password for the user.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 */
- (void)changeUserIdTo:(NSString *)newUserId password:(NSString *)currentPassword callback:(CMUserOperationCallback)callback __attribute__((deprecated));

/**
 * Asynchronously change the Email for this user. For security purposes, you must have the user enter his or her
 * current password in order to perform this operation. The user does not need to be logged in to change this property. If this method
 * is successful then the user is automatically logged in again to get their new session token. If it is not successful, the user is not logged out.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * Possible result codes:
 * - <tt>CMUserAccountEmailChangeSucceeded</tt>
 * - <tt>CMUserAccountCredentialChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateEmail</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 * - <tt>CMUserAccountUnknownResult</tt>
 *
 * @param newEmail The new email for this user.
 * @param currentPassword The current password for the user.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 */
- (void)changeEmailTo:(NSString *)newEmail password:(NSString *)currentPassword callback:(CMUserOperationCallback)callback;

/**
 * Asynchronously change the Username for this user. For security purposes, you must have the user enter his or her
 * current password in order to perform this operation. The user does not need to be logged in to change this property. If this method
 * is successful then the user is automatically logged in again to get their new session token. If it is not successful, the user is not logged out.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * Possible result codes:
 * - <tt>CMUserAccountUsernameChangeSucceeded</tt>
 * - <tt>CMUserAccountCredentialChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateUsername</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 * - <tt>CMUserAccountUnknownResult</tt>
 *
 * @param newUsername The new Username for this user.
 * @param currentPassword The current password for the user.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 */
- (void)changeUsernameTo:(NSString *)newUsername password:(NSString *)currentPassword callback:(CMUserOperationCallback)callback;

/**
 * <strong>DEPRECATED:</strong> Use <tt>changeUserCredentialsWithPassword:newPassword:newUsername:newEmail:callback:</tt> instead.
 *
 * Asynchronously change the credentials for this user. This method can be called with any combination of new values for the user.
 * It is useful when you want to change more than one value for the user, such as his username, userId, <em>and</em> password.
 * For any operation, the current password must be provided. The user does not need to be logged in to use this method.
 * If this method is successful then the user is automatically logged in again to get their new session token. If it is not successful, the user is not logged out.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * Possible result codes:
 * - <tt>CMUserAccountPasswordChangeSucceeded</tt>
 * - <tt>CMUserAccountUserIdChangeSucceeded</tt>
 * - <tt>CMUserAccountUsernameChangeSucceeded</tt>
 * - <tt>CMUserAccountCredentialsChangeSucceeded</tt> Used if more than one credential field was changed.
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateUserId</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateUsername</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateInfo</tt>
 * - <tt>CMUserAccountCredentialChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 * - <tt>CMUserAccountUnknownResult</tt>
 *
 * @param currentPassword The new password for this user.
 * @param newPassword Can be nil. The new password for the user.
 * @param newUsername Can be nil. The new username for this user.
 * @param newUserId Can be nil. The new userId for this user.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 */
- (void)changeUserCredentialsWithPassword:(NSString *)currentPassword
                              newPassword:(NSString *)newPassword
                              newUsername:(NSString *)newUsername
                                newUserId:(NSString *)newUserId
                                 callback:(CMUserOperationCallback)callback __attribute__((deprecated));

/**
 * Asynchronously change the credentials for this user. This method can be called with any combination of new values for the user.
 * It is useful when you want to change more than one value for the user, such as his username, email, <em>and</em> password.
 * For any operation, the current password must be provided. The user does not need to be logged in to use this method.
 * If this method is successful then the user is automatically logged in again to get their new session token. If it is not successful, the user is not logged out.
 * On completion, the <tt>callback</tt> block will be called with the result of the operation and any messages
 * returned by the server contained in an array. See the CloudMine documentation online for the possible contents of this array.
 *
 * Possible result codes:
 * - <tt>CMUserAccountPasswordChangeSucceeded</tt>
 * - <tt>CMUserAccountEmailChangeSucceeded</tt>
 * - <tt>CMUserAccountUsernameChangeSucceeded</tt>
 * - <tt>CMUserAccountCredentialsChangeSucceeded</tt> Used if more than one credential field was changed.
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateEmail</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateUsername</tt>
 * - <tt>CMUserAccountCredentialChangeFailedDuplicateInfo</tt>
 * - <tt>CMUserAccountCredentialChangeFailedInvalidCredentials</tt>
 * - <tt>CMUserAccountOperationFailedUnknownAccount</tt>
 * - <tt>CMUserAccountUnknownResult</tt>
 *
 * @param currentPassword The new password for this user.
 * @param newPassword Can be nil. The new password for the user.
 * @param newUsername Can be nil. The new username for this user.
 * @param newEmail Can be nil. The new email for this user.
 * @param callback The block that will be called on completion of the operation.
 *
 * @see CMUserAccountResult
 */
- (void)changeUserCredentialsWithPassword:(NSString *)currentPassword
                              newPassword:(NSString *)newPassword
                              newUsername:(NSString *)newUsername
                                 newEmail:(NSString *)newEmail
                                 callback:(CMUserOperationCallback)callback;

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
 * @see https://cloudmine.me/docs/ios/reference#users_pass_reset
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
 * Fetches the user's account from the server and updates the local user with the values received. This will override any local changes that have 
 * been made.
 *
 * This is a better way to work with the <code>save:</code> method, as it will not force a refresh of the session-token;
 *
 * @param callback The block that will be called on completion of the operation.
 */
- (void)getProfile:(CMUserOperationCallback)callback;

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
 * @param query The search query to run against all user profiles. This is the same syntax as defined at https://cloudmine.me/docs/api#query_syntax and used by <tt>CMStore</tt>'s search methods.
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

/**
 * Asynchronously adds a payment method (A credit card) to the user. The user should be logged in.
 *
 * @param paymentMethod The Credit Card you are adding.
 * @param callback The block that will be called on completion of the operation.
 */
- (void)addPaymentMethod:(CMCardPayment *)paymentMethod callback:(CMPaymentServiceCallback)callback;

/**
 * Asynchronously adds payment methods (credit cards) to the user. The user should be logged in.
 *
 * @param paymentMethods The Credit Cards (CMPayment) you are adding.
 * @param callback The block that will be called on completion of the operation.
 */
- (void)addPaymentMethods:(NSArray *)paymentMethods callback:(CMPaymentServiceCallback)callback;

/**
 * Asynchronously removes a payment (A credit card) from the user. The user should be logged in. The
 * index is which credit card you want to remove.
 *
 * @param index The index for the Payment you are removing.
 * @param callback The block that will be called on completion of the operation.
 */
- (void)removePaymentMethodAtIndex:(NSUInteger)index callback:(CMPaymentServiceCallback)callback;

/**
 * Asynchronously fetches the payment methods for the user. The user should be logged in.
 *
 * @param callback The block that will be called on completion of the operation.
 */
- (void)paymentMethods:(CMPaymentServiceCallback)callback;

@end
