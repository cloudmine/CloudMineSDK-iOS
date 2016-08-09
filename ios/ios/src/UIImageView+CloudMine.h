//
//  UIImageView+CloudMine.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 1/15/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMUser;

@interface UIImageView (CloudMine)


/**
 
 */
- (void)setImageWithFileKey:(nonnull NSString *)fileKey;

/**
 
 */
- (void)setImageWithFileKey:(nonnull NSString *)fileKey placeholderImage:(nullable UIImage *)placeholderImage;

- (void)setImageWithFileKey:(nonnull NSString *)fileKey placeholderImage:(nullable UIImage *)placeholderImage user:(nullable CMUser *)user;

@end
