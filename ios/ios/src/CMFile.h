//
//  CMFile.h
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <Foundation/Foundation.h>

@class CMUser;

@interface CMFile : NSObject<NSCoding> {
@private
    NSString *uuid;
    NSURL *cacheLocation;
}

@property (atomic, strong, readonly) NSData *fileData;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, readonly) NSURL *cacheLocation;
@property (nonatomic, strong) CMUser *user;

- (id)initWithData:(NSData *)theFileData named:(NSString *)theName;
- (id)initWithData:(NSData *)theFileData named:(NSString *)theName belongingToUser:(CMUser *)theUser;

- (BOOL)isUserLevel;
- (BOOL)writeToLocation:(NSURL *)url options:(NSFileWrapperWritingOptions)options;
- (BOOL)writeToCache;

@end
