//
//  CMMimeType.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"

#import "CMMimeType.h"

SPEC_BEGIN(CMMimeTypeSpec)

describe(@"CMMimeType", ^{
    it(@"should return application/octet-stream if the extension is not registered", ^{
        [[[CMMimeType mimeTypeForExtension:@"does-not-exist"] should] equal:@"application/octet-stream"];
    });
});

SPEC_END
