//
//  CMNullStore.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMNullStore.h"

#define THROW_NULLSTORE_EXCEPTION [[NSException exceptionWithName:@"CMInvalidStoreException" reason:[NSString stringWithFormat:@"You cannot call %@ on a null store.", NSStringFromSelector(_cmd)] userInfo:nil] raise];

@implementation CMNullStore

#pragma mark - Shared store

+ (CMNullStore *)nullStore {
    static CMNullStore *_defaultStore;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultStore = [[CMNullStore alloc] init];
    });

    return _defaultStore;
}

+ (CMStore *)defaultStore {
    return [self nullStore];
}

+ (CMStore *)store {
    [[NSException exceptionWithName:@"CMInvalidStoreException" reason:@"Use +defaultStore instead. The +store method isn't valid." userInfo:nil] raise];
    __builtin_unreachable();
}

#pragma - Methods overridden to throw exceptions

- (void)allObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)allUserObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)objectsWithKeys:(NSArray *)keys additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)userObjectsWithKeys:(NSArray *)keys additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)allObjectsOfClass:(Class)klass additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)allUserObjectsOfClass:(Class)klass additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)searchObjects:(NSString *)query additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)searchUserObjects:(NSString *)query additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)fileWithName:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)userFileWithName:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileFetchCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveAll:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveAllWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveAllAppObjects:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveAllAppObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveAllUserObjects:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveAllUserObjectsWithOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveObject:(CMObject *)theObject callback:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveObject:(CMObject *)theObject additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveUserObject:(CMObject *)theObject callback:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveUserObject:(CMObject *)theObject additionalOptions:(CMStoreOptions *)options callback:(CMStoreObjectUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)deleteObject:(id<CMSerializable>)theObject additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveFileAtURL:(NSURL *)url additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveFileAtURL:(NSURL *)url named:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveUserFileAtURL:(NSURL *)url additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveUserFileAtURL:(NSURL *)url named:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveFileWithData:(NSData *)data additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveFileWithData:(NSData *)data named:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveUserFileWithData:(NSData *)data additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)saveUserFileWithData:(NSData *)data named:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreFileUploadCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)deleteFileNamed:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)deleteUserFileNamed:(NSString *)name additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)deleteObjects:(NSArray *)objects additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)deleteUserObjects:(NSArray *)objects additionalOptions:(CMStoreOptions *)options callback:(CMStoreDeleteCallback)callback {
    THROW_NULLSTORE_EXCEPTION
}

- (void)addObject:(CMObject *)theObject {
    THROW_NULLSTORE_EXCEPTION
}

- (void)addUserObject:(CMObject *)theObject {
    THROW_NULLSTORE_EXCEPTION
}

- (void)removeObject:(CMObject *)theObject {
    THROW_NULLSTORE_EXCEPTION
}

- (void)removeUserObject:(CMObject *)theObject {
    THROW_NULLSTORE_EXCEPTION
}

- (CMObjectOwnershipLevel)objectOwnershipLevel:(CMObject *)theObject {
    THROW_NULLSTORE_EXCEPTION
    __builtin_unreachable();
}

@end
