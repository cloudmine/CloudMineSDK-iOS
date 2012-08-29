//
//  CMObjectOwnershipLevel.h
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

/** @file */

/** Defines possible ownership levels of a CMObject. */
typedef enum {
    /** The ownership level could not be determined. This is usually because the object doesn't belong to a store. */
    CMObjectOwnershipUndefinedLevel = -1,

    /** The object is app-level and is owned by no particular user. */
    CMObjectOwnershipAppLevel = 0,

    /**
     * The object is owned by a particular user, specifically the user of the store where the object is held.
     * @see CMStore#user
     */
    CMObjectOwnershipUserLevel = 1
} CMObjectOwnershipLevel;
