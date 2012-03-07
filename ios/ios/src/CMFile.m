//
//  CMFile.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "SPLowVerbosity.h"

#import "CMFile.h"
#import "CMUser.h"
#import "NSString+UUID.h"

NSString * const _dataKey = @"fileData";
NSString * const _userKey = @"user";
NSString * const _nameKey = @"name";
NSString * const _uuidKey = @"uuid";
NSString * const _mimeTypeKey = @"mime";

@implementation CMFile
@synthesize fileData;
@synthesize user;
@synthesize fileName;
@synthesize mimeType;

#pragma mark - Initializers

- (id)initWithData:(NSData *)theFileData named:(NSString *)theName {
    return [self initWithData:theFileData named:theName belongingToUser:nil mimeType:nil];
}

- (id)initWithData:(NSData *)theFileData named:(NSString *)theName belongingToUser:(CMUser *)theUser mimeType:(NSString *)theMimeType {
    if (self = [super init]) {
        fileData = theFileData;
        user = theUser;
        cacheLocation = nil;
        fileName = theName;
        mimeType = (theMimeType == nil ? @"application/octet-stream" : theMimeType);
        uuid = [NSString stringWithUUID];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self initWithData:[coder decodeObjectForKey:_dataKey]
                        named:[coder decodeObjectForKey:_nameKey]
              belongingToUser:[coder decodeObjectForKey:_userKey]
                     mimeType:[coder decodeObjectForKey:_mimeTypeKey]];
    uuid = [coder decodeObjectForKey:_uuidKey];
    return self;
}

#pragma mark - Object state

- (BOOL)isUserLevel {
    return (user != nil);
}

- (NSString *)objectId {
    return fileName;
}

+ (NSString *)className {
    [NSException raise:@"CMUnsupportedOperationException" format:@"Calling +className on CMFile is not valid."];
    __builtin_unreachable();
}

#pragma mark - Persisting to disk

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:fileData forKey:_dataKey];
    if (user) {
        [coder encodeObject:user forKey:_userKey];
    }
    [coder encodeObject:fileName forKey:_nameKey];
    [coder encodeObject:uuid forKey:_uuidKey];
    [coder encodeObject:mimeType forKey:_mimeTypeKey];
}

- (BOOL)writeToLocation:(NSURL *)url options:(NSFileWrapperWritingOptions)options {
    return [NSKeyedArchiver archiveRootObject:self toFile:[url absoluteString]];
}

- (BOOL)writeToCache {
    return [self writeToLocation:[self cacheLocation] options:NSFileWrapperWritingAtomic];
}

- (NSURL *)cacheLocation {
    if (!cacheLocation) {
        // Get the Caches directory for the app.
        NSURL *cacheDirUrl = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                                    inDomain:NSUserDomainMask
                                                           appropriateForURL:nil
                                                                      create:YES
                                                                       error:nil];
        // Store user-level and app-level files in different locations.
        NSString *subdirectory = [self isUserLevel] ? @"cmUserFiles" : @"cmFiles";
        cacheDirUrl = [cacheDirUrl URLByAppendingPathComponent:subdirectory];

        // Create the app-level or user-level subdirectory if it doesn't already exist.
        [[NSFileManager defaultManager] createDirectoryAtURL:cacheDirUrl
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
        NSString *cacheFileName = $sprintf(@"%@_%@", uuid, fileName);
        cacheLocation = [cacheDirUrl URLByAppendingPathComponent:cacheFileName];
    }

    return cacheLocation;
}

@end
