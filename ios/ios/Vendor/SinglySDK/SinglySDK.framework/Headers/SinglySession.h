//
//  SinglySession.h
//  SinglySDK
//
//  Copyright (c) 2012 Singly, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "SinglyAPIRequest.h"

@class SinglySession;

/*!
 *
 * Notification raised when a session's profiles have been updated.
 *
 */
static NSString *kSinglyNotificationSessionProfilesUpdated = @"com.singly.notifications.sessionProfilesUpdates";

/*!
 *
 * @protocol SinglySessionDelegate
 * @abstract Delegate methods related to a SinglySession
 *
 */
@protocol SinglySessionDelegate <NSObject>

@required

/*!
 *
 * Delegate method for a successful service login.
 *
 * @param session The SinglySession that this delegate is firing for
 * @param service The service name for the successful login
 *
 */
- (void)singlySession:(SinglySession *)session didLogInForService:(NSString *)service;

/*!
 *
 * Delegate method for an error during service login
 *
 * @param session The SinglySession that this delegate is firing for
 * @param service The service name for the successful login
 * @param error The error that occured during login
 *
 */
- (void)singlySession:(SinglySession *)session errorLoggingInToService:(NSString *)service withError:(NSError*)error;

@end

/*!
 * Singly Session...
 *
 */
@interface SinglySession : NSObject

/*!
 *
 * The access token that will be used for all Singly API requests.
 *
 * @property accessToken
 *
 */
@property (copy) NSString *accessToken;

/*!
 *
 * The account ID associated with the current access token.
 *
 * @property accountID
 *
 */
@property (copy) NSString *accountID;

/*!
 *
 * The client ID to be used while authenticating against the Singly API.
 *
 * @property clientID
 *
 */
@property (copy) NSString *clientID;

/*!
 *
 * The client secret to be used while authenticating against the Singly API.
 *
 * @property clientSecret
 *
 */
@property (copy) NSString *clientSecret;

/*!
 *
 * Profiles of the services that the account has connected.  Will return until
 * there is a valid session.
 *
 * @property profiles
 */
@property (readonly) NSDictionary *profiles;

/*!
 *
 *
 *
 * @property delegate
 *
 */
@property (weak, atomic) id<SinglySessionDelegate> delegate;

/*!
 *
 * Access the shared session object
 *
 * This is the preferred way to use the SinglySession and you should only create
 * a new instance if you must use multiple sessions inside one app.
 *
 */
+ (SinglySession *)sharedSession;

/*!
 *
 * Get the session in a state that is ready to make API calls.
 *
 * @param block The block to run when the check is complete. It will be passed a BOOL stating if the session is ready.
 */
- (void)startSessionWithCompletionHandler:(void (^)(BOOL))block;

/*!
 *
 * Make a Singly API request and handle the result in a delegate
 *
 * @param request The SinglyAPIRequest to process
 * @param delegate The object to call when the process succeeds or errors.
 *
 */
- (void)requestAPI:(SinglyAPIRequest *)request withDelegate:(id<SinglyAPIRequestDelegate>)delegate;

/*!
 *
 * Make a Singly API request and handle the result in a block
 *
 * @param request The SinglyAPIRequest to process
 * @param block The block to call when the request is complete.
 */
- (void)requestAPI:(SinglyAPIRequest *)request withCompletionHandler:(void (^)(NSError *, id))block;

/*!
 *
 * Explicitly go and update the profiles
 *
 * @param block The block to call when the profile update is complete
 *
 */
- (void)updateProfilesWithCompletion:(void (^)())block;


/*!
 *
 * Handles app launches by oauth redirection requests and maps them appropriately
 * based on the service.
 *
 * @param url The redirection URL that should be handled
 *
 */
- (BOOL)handleOpenURL:(NSURL *)url;

@end

