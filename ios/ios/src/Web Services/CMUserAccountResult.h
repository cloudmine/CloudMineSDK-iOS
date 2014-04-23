//
//  CMUserAccountResult.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

/**
 * @enum CMUserAccountResult Enumeration of possible results from any user account management operation (login, logout, etc).
 */
typedef enum {
    /** The response from the server was unknown or unexpected. */
    CMUserAccountUnknownResult = -1,
    /** The account login operation succeeded */
    CMUserAccountLoginSucceeded = 0,
    /** The account logout operation succeeded */
    CMUserAccountLogoutSucceeded,
    /** The account create operation succeeded */
    CMUserAccountCreateSucceeded,
    /** The user profile update succeeded */
    CMUserAccountProfileUpdateSucceeded,
    /** The password change for a user succeeded */
    CMUserAccountPasswordChangeSucceeded,
    /** The user ID change for a user succeeded */
    CMUserAccountUserIdChangeSucceeded __attribute__((deprecated)),
    /** The user email change for a user succeeded */
    CMUserAccountEmailChangeSucceeded,
    /** The user Username change for a user succeeded */
    CMUserAccountUsernameChangeSucceeded,
    /** The user credentials change succeeded */
    CMUserAccountCredentialChangeSucceeded,
    /** The forgotten password email was sent for the user */
    CMUserAccountPasswordResetEmailSent,
    /** The credential change for a user failed due to an incorrect password/user */
    CMUserAccountCredentialChangeFailedInvalidCredentials,
    /** Account creation failed because of an invalid email address or password */
    CMUserAccountCreateFailedInvalidRequest,
    /** The user profile update failed. See the accompanying dictionary for reasons. */
    CMUserAccountProfileUpdateFailed,
    /** Account creation failed because a user with that email address already exists for the current app */
    CMUserAccountCreateFailedDuplicateAccount,
    /** The user credential change failed because the new User ID was already taken */
    CMUserAccountCredentialChangeFailedDuplicateUserId __attribute__((deprecated)),
    /** The user credential change failed because the new email was already taken */
    CMUserAccountCredentialChangeFailedDuplicateEmail,
    /** The user credential change failed because the new Username was already taken */
    CMUserAccountCredentialChangeFailedDuplicateUsername,
    /** The user credential change failed because the new Username OR User ID was already taken */
    CMUserAccountCredentialChangeFailedDuplicateInfo,
    /** The login failed due to an incorrect password for the given email address */
    CMUserAccountLoginFailedIncorrectCredentials,
    /** The password change for a user failed due to an incorrect password for the given email address */
    CMUserAccountPasswordChangeFailedInvalidCredentials,
    /** A (potentially recoverable) error occured while socially logging in */
    CMUserAccountSocialLoginErrorOccurred,
    /** The Social Login OAuth window was dismissed by the user */
    CMUserAccountSocialLoginDismissed,
    /** The user account operation failed because an account with the given email address could not be found */
    CMUserAccountOperationFailedUnknownAccount
    
} CMUserAccountResult;

/**
 * Convenience method to check if a particular <tt>CMUserAccountResult</tt> code represents
 * a successful operation.
 *
 * @return <tt>YES</tt> if the operation was successful, <tt>NO</tt> otherwise.
 */
static inline BOOL CMUserAccountOperationSuccessful(CMUserAccountResult resultCode) {
    return (resultCode >= 0 && resultCode <= 9);
}

/**
 * Convenience method to check if a particular <tt>CMUserAccountResult</tt> code represents
 * a failed operation.
 *
 * @return <tt>YES</tt> if the operation failed, <tt>NO</tt> otherwise.
 */
static inline BOOL CMUserAccountOperationFailed(CMUserAccountResult resultCode) {
    return !CMUserAccountOperationSuccessful(resultCode);
}
