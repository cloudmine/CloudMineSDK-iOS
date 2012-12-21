//
//  CMAppDelegateBase.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMAppDelegateBase.h"
#import "CMWebService.h"

@implementation CMAppDelegateBase

@synthesize callback, service, user;

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    if (self.service != nil) {
        [self.service registerForPushNotificationsWithUser:user token:devToken callback:^(CMDeviceTokenResult result) {
            if (callback) {
                callback(result);
            }
        }];
    } else {
        NSLog(@"CloudMine *** Error in CMAppDelegate - service was nil when trying to register. You must set service for this to register the token. This happens automatically when you call CMStore registerForPushNotifications:");
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"CloudMine *** Error in token registration with Apple. To Handle this error override application:didFailToRegisterForRemoteNotificationsWithError: in your own App Delegate. Error: %@", err);
}

@end
