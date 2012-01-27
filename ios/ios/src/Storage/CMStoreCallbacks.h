//
//  CMStoreCallbacks.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

@class CMFile;

/**
 * Callback block signature for all operations on <tt>CMStore</tt> that fetch objects
 * from the CloudMine servers. These block should return <tt>void</tt> and take an
 * <tt>NSArray</tt> of objects as an argument.
 */
typedef void (^CMStoreObjectFetchCallback)(NSArray *objects);

typedef void (^CMStoreObjectUploadCallback)(NSDictionary *uploadStatuses, NSError *error);

typedef void (^CMStoreFileCallback)(CMFile *file);
