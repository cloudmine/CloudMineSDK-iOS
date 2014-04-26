//
//  CMFile.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMFile.h"
#import "CMUser.h"
#import "NSString+UUID.h"
#import "CMStore.h"
#import "CMNullStore.h"

NSString * const _dataKey = @"fileData";
NSString * const _nameKey = @"name";
NSString * const _uuidKey = @"uuid";
NSString * const _mimeTypeKey = @"mime";

@implementation CMFile {
    NSURL *cacheLocation;
}

@synthesize fileData;
@synthesize fileName;
@synthesize mimeType;
@synthesize store;
@synthesize uuid;

#pragma mark - Initializers

- (id)initWithData:(NSData *)theFileData named:(NSString *)theName {
    return [self initWithData:theFileData named:theName mimeType:nil];
}

- (id)initWithData:(NSData *)theFileData named:(NSString *)theName mimeType:(NSString *)theMimeType {
    if (self = [super init]) {
        fileData = theFileData;
        cacheLocation = nil;
        fileName = theName;
        mimeType = (theMimeType == nil ? @"application/octet-stream" : theMimeType);
        uuid = [NSString stringWithUUID];
        store = nil;
    }
    return self;
}

- (id)initWithData:(NSData *)theFileData named:(NSString *)theName belongingToUser:(CMUser *)theUser mimeType:(NSString *)theMimeType {
    NSLog(@"*** DEPRECATION WARNING: CMFile#initWithData:named:belongingToUser:mimeType: has been deprecated. Use CMFile#initWithData:named:mimeType: instead.");
    return [self initWithData:theFileData named:theName mimeType:theMimeType];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self initWithData:[coder decodeObjectForKey:_dataKey]
                        named:[coder decodeObjectForKey:_nameKey]
                     mimeType:[coder decodeObjectForKey:_mimeTypeKey]];
    uuid = [coder decodeObjectForKey:_uuidKey];
    return self;
}

#pragma mark - Object state

- (BOOL)isUserLevel {
    NSLog(@"*** DEPRECATION WARNING: CMFile#isUserLevel has been deprecated. Use CMFile#ownershipLevel instead.");
    return (store.user != nil);
}

- (CMUser *)user {
    return store.user;
}

- (NSString *)objectId {
    return fileName;
}

+ (NSString *)className {
    [NSException raise:@"CMUnsupportedOperationException" format:@"Calling +className on CMFile is not valid."];
    __builtin_unreachable();
}

- (CMStore *)store {
    if (!store) {
        return [CMStore defaultStore];
    }
    return store;
}

- (void)setStore:(CMStore *)newStore {
    @synchronized(self) {
        if(!newStore) {
            // An object without a store is kind of in a weird state. So represent this
            // with a null store that throws exceptions whenever anything is called on it.
            store = [CMNullStore nullStore];
            return;
        } else if(!store || store == [CMNullStore nullStore]) {
            switch ([newStore objectOwnershipLevel:self]) {
                case CMObjectOwnershipAppLevel:
                {
                    store = newStore;
                    [store addFile:self];
                    break;
                }
                case CMObjectOwnershipUserLevel:
                {
                    store = newStore;
                    [store addUserFile:self];
                    break;
                }
                default:
                {
                    store = newStore;
                    [store addFile:self];
                    break;
                }
            }

            return;
        } else if (newStore != store) {
            switch ([store objectOwnershipLevel:self]) {
                case CMObjectOwnershipAppLevel:
                {
                    // Code Coverage says this line is not executed. But it is.
                    [store removeFile:self];
                    store = newStore;
                    [newStore addFile:self];
                    break;
                }
                case CMObjectOwnershipUserLevel:
                {
                    // Code Coverage says this line is not executed. But it is.
                    [store removeUserFile:self];
                    store = newStore;
                    [newStore addUserFile:self];
                    break;
                }
                default:
                {
                    // I don't think we can actually ever get here.
                    store = newStore;
                    [store addFile:self];
                    break;
                }
            }
        }
    }
}

- (CMObjectOwnershipLevel)ownershipLevel {
    if (self.store != nil && self.store != [CMNullStore nullStore]) {
        return [self.store objectOwnershipLevel:self];
    } else {
        return CMObjectOwnershipUndefinedLevel;
    }
}

#pragma CMStore interactions

- (void)save:(CMStoreFileUploadCallback)callback {
    if ([self.store objectOwnershipLevel:self] == CMObjectOwnershipUndefinedLevel) {
        [self.store addFile:self];
    }

    switch ([self.store objectOwnershipLevel:self]) {
        case CMObjectOwnershipAppLevel:
        {
            [self.store saveFileWithData:self.fileData named:self.fileName additionalOptions:nil callback:callback];
            break;
        }
        case CMObjectOwnershipUserLevel:
        {
            [self.store saveUserFileWithData:self.fileData named:self.fileName additionalOptions:nil callback:callback];
            break;
        }
        default:
        {
            NSLog(@"*** Error: Could not save file (%@) because no store was set. This should never happen!", self);
            break;
        }
    }
}

- (void)saveWithUser:(CMUser *)user callback:(CMStoreFileUploadCallback)callback {
    NSAssert([self.store objectOwnershipLevel:self] != CMObjectOwnershipAppLevel, @"*** Error: File %@ is already at the app-level. You cannot also save it to the user level. Make a copy of it with a new objectId to do this.", self);
    if ([self.store objectOwnershipLevel:self] == CMObjectOwnershipUndefinedLevel) {
        [self.store addUserFile:self];
    }
    [self save:callback];
}

#pragma mark - Persisting to disk

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:fileData forKey:_dataKey];
    [coder encodeObject:fileName forKey:_nameKey];
    [coder encodeObject:uuid forKey:_uuidKey];
    [coder encodeObject:mimeType forKey:_mimeTypeKey];
}

- (BOOL)writeToLocation:(NSURL *)url options:(NSFileWrapperWritingOptions)options {
    return [NSKeyedArchiver archiveRootObject:self toFile:[url path]];
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
        NSString *subdirectory = self.ownershipLevel == CMObjectOwnershipUserLevel ? @"cmUserFiles" : @"cmFiles";
        cacheDirUrl = [cacheDirUrl URLByAppendingPathComponent:subdirectory];

        // Create the app-level or user-level subdirectory if it doesn't already exist.
        [[NSFileManager defaultManager] createDirectoryAtURL:cacheDirUrl
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
        
        NSString *cacheFileName = [NSString stringWithFormat:@"%@_%@", uuid, fileName];
        cacheLocation = [cacheDirUrl URLByAppendingPathComponent:cacheFileName];
    }

    return cacheLocation;
}

@end
