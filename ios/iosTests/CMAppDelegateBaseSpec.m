//
//  CMAppDelegateBaseSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMAppDelegateBase.h"
#import "CMWebService.h"
#import "CMUser.h"

SPEC_BEGIN(CMAppDelegateBaseSpec)

describe(@"CMAppDelegateBase", ^{
    
    __block CMAppDelegateBase *base = nil;
    beforeEach(^{
        base = [[CMAppDelegateBase alloc] init];
        base.service = [CMWebService mock];
        base.user = [CMUser new];
    });
    
    it(@"should have a window propery", ^{
        [[base.window should] beNil];
        [[ theValue([base respondsToSelector:@selector(window)]) should] beTrue];
    });
    
    it(@"should fail to register a token if no service has been set", ^{
        base.service = nil;
        base.callback = ^(CMDeviceTokenResult result) { };
        [base application:nil didRegisterForRemoteNotificationsWithDeviceToken:[NSData data]];
        [[base.callback shouldNot] beNil];
    });
    
    it(@"should register when given a token", ^{
        [[base.service should] receive:@selector(registerForPushNotificationsWithUser:token:callback:)];
        KWCaptureSpy *spy = [base.service captureArgument:@selector(registerForPushNotificationsWithUser:token:callback:) atIndex:2];
        
        base.callback = ^(CMDeviceTokenResult result) {
            [[theValue(result) should] equal:@(CMDeviceTokenUploadSuccess)];
        };
        [base application:nil didRegisterForRemoteNotificationsWithDeviceToken:[NSData data]];
        
        
        CMWebServiceDeviceTokenCallback callback = spy.argument;
        callback(CMDeviceTokenUploadSuccess);
        
    });
    
    it(@"should response to a failure to register", ^{
        NSError *error = [NSError errorWithDomain:@"example" code:-100 userInfo:@{@"info": @"moreinfo"}];
        [base application:[UIApplication sharedApplication] didFailToRegisterForRemoteNotificationsWithError:error];
    });
    
});

SPEC_END
