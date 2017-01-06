//
//  CMMimeType.h
//  cloudmine-ios
//
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

/**
 * Utility class for looking up MIME types for files based on the file's extension.
 */
@interface CMMimeType : NSObject

/**
 * @return The MIME type of the extension if found, <tt>nil</tt> otherwise.
 */
+ (nonnull NSString *)mimeTypeForExtension:(nonnull NSString *)extension;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

@end
