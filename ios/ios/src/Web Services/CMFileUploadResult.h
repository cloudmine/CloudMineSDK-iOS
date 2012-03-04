//
//  CMFileUploadResult.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

/**
 * @enum Enumeration of possible results from a file upload operation.
 */
typedef enum {
    /** An error ocurred when uploading the file */
    CMFileUploadFailed = -1,

    /** File was created new on the server */
    CMFileCreated = 0,

    /** File previously existed on server and was replaced with new content */
    CMFileUpdated

} CMFileUploadResult;
