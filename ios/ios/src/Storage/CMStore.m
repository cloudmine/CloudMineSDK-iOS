//
//  CMStore.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStore.h"

#import "CMObjectDecoder.h"
#import "CMObjectEncoder.h"
#import "CMObjectSerialization.h"
#import "CMAPICredentials.h"

#define _CMAssertAPICredentialsInitialized NSAssert([[CMAPICredentials sharedInstance] apiKey] != nil && [[[CMAPICredentials sharedInstance] apiKey] length] > 0 && [[CMAPICredentials sharedInstance] appKey] != nil && [[[CMAPICredentials sharedInstance] appKey] length] > 0, @"The CMAPICredentials singleton must be initialized before using a CloudMine Store")

@implementation CMStore
@synthesize webService;

#pragma mark - Initializers

+ (CMStore *)store {
    return [[self alloc] init];
}

- (id)init {
    if (self = [super init]) {
        self.webService = [[CMWebService alloc] init];
    }
    return self;
}

#pragma mark - Object retrieval

- (void)allObjects:(CMStoreObjectCallback)callback additionalOptions:(CMStoreOptions *)options {
    NSParameterAssert(callback);
    _CMAssertAPICredentialsInitialized;
    
    [webService getValuesForKeys:nil
              serverSideFunction:options.serverSideFunction
                   pagingOptions:options.pagingDescriptor 
                            user:nil
                  successHandler:^(NSDictionary *results, NSDictionary *errors) {
                      callback([CMObjectDecoder decodeObjects:results]);
                  } errorHandler:^(NSError *error) {
                      NSLog(@"Error occurred during request: %@", [error description]);
                      callback(nil);
                  }
     ];
}

- (void)allObjects:(CMStoreObjectCallback)callback ofType:(NSString *)type additionalOptions:(CMStoreOptions *)options {
    NSParameterAssert(callback);
    NSParameterAssert(type);
    _CMAssertAPICredentialsInitialized;
    
    [webService searchValuesFor:[NSString stringWithFormat:@"[%@ = \"%@\"]", CM_INTERNAL_TYPE_STORAGE_KEY, type]
             serverSideFunction:options.serverSideFunction
                  pagingOptions:options.pagingDescriptor 
                           user:nil
                 successHandler:^(NSDictionary *results, NSDictionary *errors) {
                     callback([CMObjectDecoder decodeObjects:results]);
                 } errorHandler:^(NSError *error) {
                     NSLog(@"Error occurred during request: %@", [error description]);
                     callback(nil);
                 }
     ];
}

@end
