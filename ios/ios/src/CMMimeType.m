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

    return [[_mimeTypeExtensionMappings objectForKey:extension] copy];
}

+ (void)loadMimeTypes {
    if (_mimeTypeExtensionMappings == nil) {
        _mimeTypeExtensionMappings = [NSDictionary dictionaryWithObjectsAndKeys:@"image/bmp", @".bmp",
                                      @"image/gif", @".gif",
                                      @"image/x-icon", @".ico",
                                      @"image/jpeg", @".jfif",
                                      @"image/jpeg", @".jpe",
                                      @"image/jpeg", @".jpeg",
                                      @"image/jpeg", @".jpg",
                                      @"image/vnd.ms-modi", @".mdi",
                                      @"image/pict", @".pct",
                                      @"image/pict", @".pict",
                                      @"image/photoshop", @".psd",
                                      @"image/x-quicktime", @".qtif",
                                      @"image/rle", @".rle",
                                      @"image/tiff", @".tif",
                                      @"image/tiff", @".tiff",
                                      @"image/wmf", @".wmf",
                                      @"image/x-xbitmap", @".xbm",
                                      @"video/x-ms-asf", @".asf",
                                      @"video/x-ms-asf", @".asx",
                                      @"video/avi", @".avi",
                                      @"video/x-dv", @".dv",
                                      @"video/mpeg", @".m1v",
                                      @"video/m4v", @".m4v",
                                      @"video/quicktime", @".mov",
                                      @"video/mpeg", @".mp2v",
                                      @"video/mp4", @".mp4",
                                      @"video/mpeg", @".mpa",
                                      @"video/mpeg", @".mpe",
                                      @"video/mpeg", @".mpeg",
                                      @"video/mpeg", @".mpg",
                                      @"video/quicktime", @".mqv",
                                      @"video/quicktime", @".qt",
                                      @"video/x-ms-wm", @".wm",
                                      @"video/x-ms-wmv", @".wmv",
                                      @"video/x-ms-wmx", @".wmx",
                                      @"video/x-ms-wvx", @".wvx",
                                      @"audio/audible", @".aa",
                                      @"audio/aac", @".aac",
                                      @"audio/aac", @".adts",
                                      @"audio/aiff", @".aif",
                                      @"audio/aiff", @".aifc",
                                      @"audio/aiff", @".aiff",
                                      @"audio/amr", @".amr",
                                      @"audio/basic", @".au",
                                      @"audio/x-caf", @".caf",
                                      @"audio/aiff", @".cdda",
                                      @"audio/x-gsm", @".gsm",
                                      @"audio/mpegurl", @".m3u",
                                      @"audio/m4a", @".m4a",
                                      @"audio/m4b", @".m4b",
                                      @"audio/m4p", @".m4p",
                                      @"audio/mid", @".mid",
                                      @"audio/mid", @".midi",
                                      @"audio/mpeg", @".mp2",
                                      @"audio/mpeg", @".mp3",
                                      @"audio/ogg", @".ogg",
                                      @"audio/scpls", @".pls",
                                      @"audio/mid", @".rmi",
                                      @"audio/x-pn-realaudio", @".rmm",
                                      @"audio/x-sd2", @".sd2",
                                      @"audio/basic", @".snd",
                                      @"audio/wav", @".wav",
                                      @"audio/wav", @".wave",
                                      @"audio/x-ms-wax", @".wax",
                                      @"audio/x-ms-wma", @".wma",
                                      nil];
    }
}

@end
