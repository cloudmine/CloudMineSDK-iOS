//
//  CMStoreCallbacks.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import "CMACLFetchResponse.h"
#import "CMObjectFetchResponse.h"
#import "CMObjectUploadResponse.h"
#import "CMFileFetchResponse.h"
#import "CMFileUploadResponse.h"
#import "CMDeleteResponse.h"

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that fetch ACLs
 * from the CloudMine's servers.
 *
 * @param CMACLFetchResponse
 */
typedef void (^CMStoreACLFetchCallback)(CMACLFetchResponse *response);

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that fetch objects
 * from the CloudMine servers.
 *
 * @see CMObjectFetchResponse
 */
typedef void (^CMStoreObjectFetchCallback)(CMObjectFetchResponse *response);

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that upload objects
 * to the CloudMine servers.
 *
 * @see CMObjectUploadResponse
 */
typedef void (^CMStoreObjectUploadCallback)(CMObjectUploadResponse *response);

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that fetch binary files
 * from the CloudMine servers.
 *
 * @see CMFileFetchResponse
 */
typedef void (^CMStoreFileFetchCallback)(CMFileFetchResponse *response);

/**
 * Callback block signature for operations on <tt>CMStore</tt> that upload binary files
 * to the CloudMine servers with a given name.
 *
 * @param CMFileUploadResponse
 */
typedef void (^CMStoreFileUploadCallback)(CMFileUploadResponse *response);

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that delete objects or binary files.
 *
 * @see CMDeleteResponse
 */
typedef void (^CMStoreDeleteCallback)(CMDeleteResponse *response);
