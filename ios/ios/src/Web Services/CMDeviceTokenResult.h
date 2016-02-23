//
//  CMDeviceTokenResult.h
//  cloudmine-ios
//
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

/**
 * @enum Enumeration of possible results from the Device Token for Push
 */
typedef NS_ENUM(NSInteger, CMDeviceTokenResult){
    /** An error ocurred when working with the token */
    CMDeviceTokenOperationFailed = -1,
    
    /** Token was uploaded successfully */
    CMDeviceTokenUploadSuccess = 0,
    
    /** Device Token was previously uploaded and was updated. */
    CMDeviceTokenUpdated,
    
    /** Device Token was deleted successfully */
    CMDeviceTokenDeleted
};

/**
 * Callback block signature for all operations that work with the Device Token for Push Notifications.
 * These block return <tt>void</tt> and take an enum for the result.
 *
 * @see CMDeviceTokenResult
 */
typedef void (^CMWebServiceDeviceTokenCallback)(CMDeviceTokenResult result);
