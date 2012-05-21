//
//  CMStoreCallbacks.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

#import "CMFileUploadResult.h"
#import "CMObjectFetchResponse.h"
#import "CMObjectUploadResponse.h"
#import "CMFileFetchResponse.h"
#import "CMFileUploadResponse.h"
#import "CMDeleteResponse.h"

@class CMFile;

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that fetch objects
 * from the CloudMine servers. This block should return <tt>void</tt> and take an
 * <tt>NSArray</tt> of objects as an argument.
 */
typedef void (^CMStoreObjectFetchCallback)(CMObjectFetchResponse *response);

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that upload objects
 * to the CloudMine servers. This block should return <tt>void</tt> and take one parameter,
 * a dictionary mapping object or file names to success status messages (such as "updated", "created", etc),
 */
typedef void (^CMStoreObjectUploadCallback)(CMObjectUploadResponse *response);

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that fetch binary files
 * from the CloudMine servers. This block should return <tt>void</tt> and take a single
 * <tt>CMFile</tt> as an argument. This will contain the data as well as a bit of metadata
 * about the file that was downloaded.
 */
typedef void (^CMStoreFileFetchCallback)(CMFileFetchResponse *response);

/**
 * Callback block signature for operations on <tt>CMStore</tt> that upload binary files
 * to the CloudMine servers with a given name. This block should return <tt>void</tt> and take a single
 * <tt>CMFileUploadResult</tt> as an argument. This represents the result of the upload (namely, whether
 * the upload created a new file or updated an old one), and the name of the new file.
 */
typedef void (^CMStoreFileUploadCallback)(CMFileUploadResponse *response);

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that delete objects or binary files.
 * This block should return <tt>void</tt> and take a single boolean as an argument. It will be <tt>YES</tt> if
 * the objects/files were deleted successfully, and <tt>NO</tt> otherwise. If files were not successfully deleted, check
 * <tt>CMStore#lastError</tt> for details.
 *
 * @see CMStore#deleteObject:callback:
 */
typedef void (^CMStoreDeleteCallback)(CMDeleteResponse *response);
