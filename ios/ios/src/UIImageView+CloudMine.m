//
//  UIImageView+CloudMine.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 1/15/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "UIImageView+CloudMine.h"
#import "CMStore.h"

@interface CMImageCache : NSCache

- (UIImage *)cachedImageForFileKey:(NSString *)fileKey;
- (void)cacheImage:(UIImage *)image forFileKey:(NSString *)fileKey;

@end

@implementation UIImageView (CloudMine)

+ (CMImageCache *)cm_sharedImageCache;
{
    static CMImageCache *_cm_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _cm_imageCache = [[CMImageCache alloc] init];
    });
    
    return _cm_imageCache;
}

- (void)setImageWithFileKey:(NSString *)fileKey;
{
    [self setImageWithFileKey:fileKey placeholderImage:nil];
}

- (void)setImageWithFileKey:(NSString *)fileKey placeholderImage:(UIImage *)placeholderImage;
{
    [self setImageWithFileKey:fileKey placeholderImage:placeholderImage user:nil];
}

- (void)setImageWithFileKey:(NSString *)fileKey placeholderImage:(UIImage *)placeholderImage user:(CMUser *)user;
{
    UIImage *cachedImage = [[[self class] cm_sharedImageCache] cachedImageForFileKey:fileKey];
    if (cachedImage) {
        self.image = cachedImage;
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }
        
        void (^callback)(CMFileFetchResponse *response) = ^(CMFileFetchResponse *response){
            UIImage *image = [UIImage imageWithData:response.file.fileData];
            self.image = image;
            [[[self class] cm_sharedImageCache] cacheImage:image forFileKey:fileKey];
        };
        
        if (user) {
            [[CMStore defaultStore] userFileWithName:fileKey additionalOptions:nil callback:callback];
        } else {
            [[CMStore defaultStore] fileWithName:fileKey additionalOptions:nil callback:callback];
        }
    }
}

@end


#pragma mark - CMImageCache

@implementation CMImageCache

- (UIImage *)cachedImageForFileKey:(NSString *)fileKey;
{
	return [self objectForKey:fileKey];
}

- (void)cacheImage:(UIImage *)image forFileKey:(NSString *)fileKey;
{
    if (image && fileKey) {
        [self setObject:image forKey:fileKey];
    }
}

@end