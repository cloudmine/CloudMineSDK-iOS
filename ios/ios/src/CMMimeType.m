//
//  CMMimeType.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
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
    
    [_mimeTypeExtensionMappings objectForKey:extension];
}

+ (void)loadMimeTypes {
    if (_mimeTypeExtensionMappings == nil) {
        _mimeTypeExtensionMappings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MimeTypes" ofType:@"plist"]];
    }
}

@end
