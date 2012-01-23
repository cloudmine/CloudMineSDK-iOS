//
//  CMStore.m
//  cloudmine-ios
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMStore.h"

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

- (NSSet *)allObjects {
    NSMutableSet *objects = [[NSMutableSet alloc] init];
    
    [webService getValuesForKeys:nil 
              serverSideFunction:nil
                  successHandler:^(NSDictionary *results, NSDictionary *errors) {
                  } errorHandler:^(NSError *error) {
                  }
     ];
    
    // Return a copy to avoid mutation.
    return [NSSet setWithSet:objects];
}

@end
