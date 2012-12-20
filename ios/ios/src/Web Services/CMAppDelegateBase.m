//
//  CMAppDelegateBase.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 12/14/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMAppDelegateBase.h"
#import "CMWebService.h"

@implementation CMAppDelegateBase

@synthesize callback, service, user;

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    [self.service registerForPushNotificationsWithUser:user token:devToken callback:^(CMDeviceTokenResult result) {
        callback(result);
    }];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"CloudMine *** Error in token registration with Apple. To Handle this error override application:didFailToRegisterForRemoteNotificationsWithError: in your own App Delegate. Error: %@", err);
}

@end
