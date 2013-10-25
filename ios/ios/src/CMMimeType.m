//
//  CMMimeType.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMMimeType.h"

static NSDictionary *_mimeTypeExtensionMappings = nil;

@interface CMMimeType (Private)
+ (void)loadMimeTypes;
@end

@implementation CMMimeType

+ (NSString *)mimeTypeForExtension:(NSString *)extension {
    if (_mimeTypeExtensionMappings == nil) {
        [self loadMimeTypes];
    }

    if (![[extension substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"."]) {
        extension = [NSString stringWithFormat:@".%@", extension];
    }

    NSString *mimeType = [[_mimeTypeExtensionMappings objectForKey:[extension lowercaseString]] copy];
    if (!mimeType) {
        mimeType = @"application/octet-stream";
    }
    return mimeType;
}

+ (void)loadMimeTypes {
    if (_mimeTypeExtensionMappings == nil) {
        _mimeTypeExtensionMappings = @{@".bmp" : @"image/bmp",
                                       @".gif" : @"image/gif",
                                       @".ico" : @"image/x-icon",
                                      @".jfif" : @"image/jpeg",
                                       @".jpe" : @"image/jpeg",
                                      @".jpeg" : @"image/jpeg",
                                       @".jpg" : @"image/jpeg",
                                       @".mdi" : @"image/vnd.ms-modi",
                                       @".pct" : @"image/pict",
                                      @".pict" : @"image/pict",
                                       @".psd" : @"image/photoshop",
                                       @".png" : @"image/png",
                                      @".qtif" : @"image/x-quicktime",
                                       @".rle" : @"image/rle",
                                       @".tif" : @"image/tiff",
                                      @".tiff" : @"image/tiff",
                                       @".wmf" : @"image/wmf",
                                       @".xbm" : @"image/x-xbitmap",
                                       @".asf" : @"video/x-ms-asf",
                                       @".asx" : @"video/x-ms-asf",
                                       @".avi" : @"video/avi",
                                        @".dv" : @"video/x-dv",
                                       @".m1v" : @"video/mpeg",
                                       @".m4v" : @"video/m4v",
                                       @".mov" : @"video/quicktime",
                                      @".mp2v" : @"video/mpeg",
                                       @".mp4" : @"video/mp4",
                                       @".mpa" : @"video/mpeg",
                                       @".mpe" : @"video/mpeg",
                                      @".mpeg" : @"video/mpeg",
                                       @".mpg" : @"video/mpeg",
                                       @".mqv" : @"video/quicktime",
                                        @".qt" : @"video/quicktime",
                                        @".wm" : @"video/x-ms-wm",
                                       @".wmv" : @"video/x-ms-wmv",
                                       @".wmx" : @"video/x-ms-wmx",
                                       @".wvx" : @"video/x-ms-wvx",
                                        @".aa" : @"audio/audible",
                                       @".aac" : @"audio/aac",
                                      @".adts" : @"audio/aac",
                                       @".aif" : @"audio/aiff",
                                      @".aifc" : @"audio/aiff",
                                      @".aiff" : @"audio/aiff",
                                       @".amr" : @"audio/amr",
                                        @".au" : @"audio/basic",
                                       @".caf" : @"audio/x-caf",
                                      @".cdda" : @"audio/aiff",
                                       @".gsm" : @"audio/x-gsm",
                                       @".m3u" : @"audio/mpegurl",
                                       @".m4a" : @"audio/m4a",
                                       @".m4b" : @"audio/m4b",
                                       @".m4p" : @"audio/m4p",
                                       @".mid" : @"audio/mid",
                                      @".midi" : @"audio/mid",
                                       @".mp2" : @"audio/mpeg",
                                       @".mp3" : @"audio/mpeg",
                                       @".ogg" : @"audio/ogg",
                                       @".pls" : @"audio/scpls",
                                       @".rmi" : @"audio/mid",
                                       @".rmm" : @"audio/x-pn-realaudio",
                                       @".sd2" : @"audio/x-sd2",
                                       @".snd" : @"audio/basic",
                                       @".wav" : @"audio/wav",
                                      @".wave" : @"audio/wav",
                                       @".wax" : @"audio/x-ms-wax",
                                       @".wma" : @"audio/x-ms-wma"};
    }
}

@end
