//
//  CMMimeType.m
//  cloudmine-iosTests
//
//  Copyright (c) 2015 CloudMine, Inc. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMMimeType.h"

SPEC_BEGIN(CMMimeTypeSpec)

describe(@"CMMimeType", ^{
    it(@"should return application/octet-stream if the extension is not registered", ^{
        [[[CMMimeType mimeTypeForExtension:@"does-not-exist"] should] equal:@"application/octet-stream"];
    });

    it(@"should be case insensitive", ^{
        NSString *mimeType = [CMMimeType mimeTypeForExtension:@".png"];
        [[mimeType shouldNot] equal:@"application/octet-stream"];
        [[[CMMimeType mimeTypeForExtension:@".PNG"] should] equal:mimeType];
    });

    it(@"should work with or without a leading period", ^{
        NSString *mimeType = [CMMimeType mimeTypeForExtension:@".png"];
        [[mimeType shouldNot] equal:@"application/octet-stream"];
        [[[CMMimeType mimeTypeForExtension:@"png"] should] equal:mimeType];
        [[[CMMimeType mimeTypeForExtension:@"PNG"] should] equal:mimeType];
    });
});

SPEC_END
