//
//  CMAppDelegateBase.h
//  cloudmine-ios
//
//  Created by Ethan Mick on 12/14/12.
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMDeviceTokenResult.h"

@class CMWebService, CMUser;

@interface CMAppDelegateBase : UIResponder <UIApplicationDelegate>

@property (atomic, strong) CMWebServiceDeviceTokenCallback callback;
@property (atomic, strong) CMWebService *service;
@property (atomic, strong) CMUser *user;
@property (nonatomic, strong) UIWindow *window;


/**
 * If you implement this method in your Application Delegate (for example, to do something else with the devToken,
 * then you MUST call super BEFORE doing anything to the devToken. We do not modify the devToken in anyway, so you
 * should call super first to ensure we don't get a malformed token.
 */
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;

@end
