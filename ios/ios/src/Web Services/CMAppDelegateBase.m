//
//  CMAppDelegateBase.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 12/14/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import "CMAppDelegateBase.h"

@implementation CMAppDelegateBase

@synthesize user, callback;

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    [self.user registerDeviceForPushNotificationsWithToken:devToken callback:self.callback];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"CloudMine *** Error in token registration with Apple. To Handle this error override application:didFailToRegisterForRemoteNotificationsWithError: in your own App Delegate. Error: %@", err);
}

@end
