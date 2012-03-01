//
//  CMUserAccountResult.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

/**
 * @enum Enumeration of possible results from any user account management operation (login, logout, etc).
 */
typedef enum {
    CMUserAccountUnknownResult = -1,
    CMUserAccountLoginSucceeded = 0,
    CMUserAccountLogoutSucceeded,
    CMUserAccountPasswordChangeSucceeded,
    CMUserAccountPasswordResetEmailSent,
    
    CMUserAccountCreateFailedInvalidRequest,
    CMUserAccountCreateFailedDuplicateAccount,
    CMUserAccountLoginFailedIncorrectCredentials,
    CMUserAccountPasswordChangeFailedInvalidCredentials,
    CMUserAccountPasswordResetFailedUnknownAccount
    
} CMUserAccountResult;

static inline BOOL CMUserAccountOperationSuccessful(CMUserAccountResult resultCode) {
    return (resultCode >= 0 && resultCode <= 3);
}

static inline BOOL CMUserAccountOperationFailed(CMUserAccountResult resultCode) {
    return !CMUserAccountOperationSuccessful(resultCode);
}