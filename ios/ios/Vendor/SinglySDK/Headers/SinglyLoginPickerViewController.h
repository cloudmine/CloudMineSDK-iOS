//
//  SinglyLoginPickerViewController.h
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

#import <SinglySDK/SinglySession.h>
#import <SinglySDK/SinglyLoginViewController.h>

/*!
 *
 * Displays a list of services that can be authenticated against in a list view
 * with the option to log in to any supported services.
 *
 */
@interface SinglyLoginPickerViewController : UITableViewController <SinglySessionDelegate,
    SinglyLoginViewControllerDelegate, UIAlertViewDelegate>

/*!
 *
 * The services that should be displayed in the picker. This defaults to all of
 * the available services as returned by servicesDictionary, but can be
 * set to just the services you require.
 *
 */
@property (nonatomic, strong) NSArray *services;

/*!
 *
 * A dictionary containing metadata describing all of the supported services.
 * The dictionary is automatically populated from the Singly API.
 *
 */
@property (nonatomic, strong, readonly) NSDictionary *servicesDictionary;

/*!
 *
 * The SinglySession to use for the login requests. The default value of this is
 * the shared singleton instance.
 *
 */
@property (nonatomic, strong) SinglySession *session;

- (id)initWithSession:(SinglySession *)session;

@end
