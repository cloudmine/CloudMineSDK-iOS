#import "CMLegacyCacheCleaner.h"

@implementation CMLegacyCacheCleaner

#pragma MARK Public

+ (void)cleanLegacyCache
{
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        dispatch_async(backgroundQueue, ^{
            for (NSString *path in [self cacheDirectories]) {
                [self deleteDirectoryWithPath:path];
            }
        });
    });
}

#pragma MARK Helpers

+ (NSArray<NSString *> *)cacheDirectories
{
    NSMutableArray *cacheDirs = [NSMutableArray new];

    for (NSString *directory in @[@"cmFiles", @"cmUserFiles"]) {
        NSString *path = [self cacheDirectoryWithPath:directory];

        if (nil != path) {
            [cacheDirs addObject:path];
        }
    }

    return [cacheDirs copy];
}

+ (NSString *)cacheDirectoryWithPath:(NSString *)path
{
    NSURL *cacheDirUrl = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                                inDomain:NSUserDomainMask
                                                       appropriateForURL:nil
                                                                  create:YES
                                                                   error:nil];

    cacheDirUrl = [cacheDirUrl URLByAppendingPathComponent:path];

    return cacheDirUrl.relativePath;
}

+ (void)deleteDirectoryWithPath:(NSString *)path
{
    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
        NSError *error = nil;
        BOOL success = [NSFileManager.defaultManager removeItemAtPath:path error:&error];

        if (!success) {
            NSLog(@"Error clearing local cache: %@", error.localizedDescription);
        }
    }
}


@end
