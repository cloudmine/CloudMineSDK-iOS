//
//  SinglyLogInViewController.h
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

#import <UIKit/UIKit.h>
#import "SinglySession.h"

@class SinglyLoginViewController;

@protocol SinglyLoginViewControllerDelegate <NSObject>

- (void)singlyLoginViewController:(SinglyLoginViewController *)controller didLoginForService:(NSString *)service;
- (void)singlyLoginViewController:(SinglyLoginViewController *)controller errorLoggingInToService:(NSString *)service withError:(NSError *)error;

@end

@interface SinglyLoginViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (weak, atomic) id<SinglyLoginViewControllerDelegate> delegate;

/*!
 *
 * The SinglySession to use for the login request. The default value of this is
 * the shared singleton instance.
 *
 */
@property (strong, nonatomic) SinglySession *session;

@property (strong, atomic) NSString *targetService;
@property (strong, atomic) NSString *scope;
@property (strong, atomic) NSString *flags;

/*!
 *
 * Initialize with a SinglySession and service identifier.
 *
 * @param session The session that the login will be saved into.
 * @param serviceId The name of the service that we are logging into.
 */
- (id)initWithSession:(SinglySession *)session forService:(NSString *)serviceId;

@end
