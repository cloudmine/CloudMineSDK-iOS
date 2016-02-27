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
- (void)setImageWithFileKey:(NSString *)fileKey;

/**
 
 */
- (void)setImageWithFileKey:(NSString *)fileKey placeholderImage:(UIImage *)placeholderImage;

- (void)setImageWithFileKey:(NSString *)fileKey placeholderImage:(UIImage *)placeholderImage user:(CMUser *)user;

@end
