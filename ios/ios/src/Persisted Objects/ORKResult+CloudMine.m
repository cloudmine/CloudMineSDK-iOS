//
//  ORKResult+CloudMine.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 1/12/16.
//  Copyright © 2016 CloudMine, LLC. All rights reserved.
//

#import "ORKResult+CloudMine.h"
#import "CMWebService.h"
#import "CMObjectEncoder.h"

@implementation ORKResult (CloudMine)

- (void)save:(CMStoreObjectUploadCallback)callback;
{
    NSDictionary *objects = [CMObjectEncoder encodeObjects:@[self]];
    [[CMStore defaultStore] _saveSerializedObjects:objects
                                         userLevel:nil callback:^(CMObjectUploadResponse *response) {
                                             NSLog(@"Response %@", response.uploadStatuses);
    } additionalOptions:nil];
    
}

- (void)saveWithUser:(CMUser *)user callback:(CMStoreObjectUploadCallback)callback;
{
    
}

@end
