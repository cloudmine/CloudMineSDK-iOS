//
//  CMWebServiceIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/13/14.
//  Copyright (c) 2014 CloudMine, LLC. All rights reserved.
//

#import "Kiwi.h"
#import "CMWebService.h"
#import "CMAPICredentials.h"
#import "CMUser.h"

SPEC_BEGIN(CMWebServiceIntegrationSpec)

describe(@"CMWebServiceIntegration", ^{
    
    __block CMWebService *service = nil;
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:@"9977f87e6ae54815b32a663902c3ca65"];
        [[CMAPICredentials sharedInstance] setAppSecret:@"c701d73554594315948c8d3cc0711ac1"];
        
        service = [[CMWebService alloc] init];
        
    });
    
    context(@"snippets", ^{
        
        it(@"should correctly run a normal snippet", ^{
            
            __block NSDictionary *result = nil;
            __block NSError *err = nil;
            [service runSnippet:@"store_integration" withParams:nil user:nil successHandler:^(id snippetResult, NSDictionary *headers) {
                result = snippetResult;
            } errorHandler:^(NSError *error) {
                err = error;
            }];
            
            [[expectFutureValue(result) shouldEventually] beNonNil];
            [[expectFutureValue(err) shouldEventually] beNil];
            [[expectFutureValue(result[@"store"]) shouldEventually] equal:@"integration"];
        });
        
        it(@"should correctly send parameters to the snippet", ^{
            
            __block NSDictionary *result = nil;
            __block NSError *err = nil;
            [service runSnippet:@"store_params" withParams:@{@"my_param": @"15"} user:nil successHandler:^(id snippetResult, NSDictionary *headers) {
                result = snippetResult;
            } errorHandler:^(NSError *error) {
                err = error;
            }];
            
            [[expectFutureValue(result) shouldEventually] beNonNil];
            [[expectFutureValue(err) shouldEventually] beNil];
            [[expectFutureValue(result[@"params"][@"my_param"]) shouldEventually] equal:@"15"];
        });
        
        it(@"should correctly run a POST snippet", ^{
            __block NSDictionary *result = nil;
            __block NSError *err = nil;
            
            NSDictionary *dict = @{@"some_data": @"hello"};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            
            [service runPOSTSnippet:@"post" withBody:data user:nil successHandler:^(id snippetResult, NSDictionary *headers) {
                result = snippetResult;
                NSLog(@"result: %@", result);
            } errorHandler:^(NSError *error) {
                err = error;
            }];
            
            [[expectFutureValue(result) shouldEventually] beNonNil];
            [[expectFutureValue(err) shouldEventually] beNil];
            [[expectFutureValue(result[@"data"][@"some_data"]) shouldEventually] equal:@"hello"];
        });
    });
    
    context(@"social login", ^{
        
#warning update these tests
        it(@"should create the login controller", ^{
            CMUser *user = [[CMUser alloc] init];
            
            CMSocialLoginViewController *controller =  [service loginWithSocial:user
                                                                    withService:CMSocialNetworkTwitter
                                                                 viewController:nil
                                                                         params:@{@"scope": @"email"}
                                                                       callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
                                                                           
                                                                       }];
            // Twitter will return nil
            [[controller should] beNil];
        });
        
        it(@"should fail to login a user without a valid challenge", ^{
            [service cmSocialLoginViewController:nil completeSocialLoginWithChallenge:@"challenge"];
        });
        
        it(@"should propogate the error back to the callback", ^{
            NSError *error = [NSError errorWithDomain:@"Domain" code:-100 userInfo:@{}];
            [service cmSocialLoginViewController:nil hadError:error];
        });
        
        it(@"should inform the callback it was dismissed", ^{
            [service cmSocialLoginViewControllerWasDismissed:nil];
        });
        
    });
    
    
    context(@"push notifications", ^{
        
        __block CMUser *user = nil;
        __block NSString *channelName = nil;
        beforeAll(^{
            user = [[CMUser alloc] initWithEmail:@"cm_push_notification_user@cloudmine.me" andPassword:@"testing"];
            
            __block CMUserAccountResult code = NSNotFound;
            [user createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                code = resultCode;
            }];
            
            [[expectFutureValue(theValue(code)) shouldEventually] equal:@(CMUserAccountLoginSucceeded)];
            
            __block NSDictionary *result = nil;
            __block NSError *err = nil;
            [service runSnippet:@"create_channel" withParams:nil user:nil successHandler:^(id snippetResult, NSDictionary *headers) {
                result = snippetResult;
                channelName = result[@"name"];
                NSLog(@"Result: %@", result);
            } errorHandler:^(NSError *error) {
                err = error;
            }];
            
            [[expectFutureValue(result) shouldEventually] beNonNil];
            [[expectFutureValue(err) shouldEventually] beNil];
            [[expectFutureValue(channelName) shouldEventually] beNonNil];
        });
        
        it(@"should fail to unregister a token when none is registered", ^{
            
            __block CMDeviceTokenResult res = NSNotFound;
            [service unRegisterForPushNotificationsWithUser:user callback:^(CMDeviceTokenResult result) {
                res = result;
            }];
            
            [[expectFutureValue(theValue(res)) shouldEventually] equal:@(CMDeviceTokenOperationFailed)];
        });
        
        it(@"should let the user upload a device token", ^{
            NSString *token = @"<c7e265d1 cbd443b3 ee80fd07 c892a8b8 f20c08c4 91fa11f2 535f2ccf ad7f55ef>";
            NSData *data = [token dataUsingEncoding:NSUTF8StringEncoding];
            
            __block CMDeviceTokenResult res = NSNotFound;
            [service registerForPushNotificationsWithUser:user token:data callback:^(CMDeviceTokenResult result) {
                res = result;
            }];
            
            [[expectFutureValue(theValue(res)) shouldEventually] equal:@(CMDeviceTokenUploadSuccess)];
        });
        
        it(@"should let the user upload the token again and get a 200", ^{
            NSString *token = @"<c7e265d1 cbd443b3 ee80fd07 c892a8b8 f20c08c4 91fa11f2 535f2ccf ad7f55ef>";
            NSData *data = [token dataUsingEncoding:NSUTF8StringEncoding];
            
            __block CMDeviceTokenResult res = NSNotFound;
            [service registerForPushNotificationsWithUser:user token:data callback:^(CMDeviceTokenResult result) {
                res = result;
            }];
            
            [[expectFutureValue(theValue(res)) shouldEventually] equal:@(CMDeviceTokenUpdated)];
        });
        
        it(@"should get the push channels", ^{
            
            __block CMViewChannelsResponse *res = nil;
            [service getChannelsForThisDeviceWithCallback:^(CMViewChannelsResponse *response) {
                res = response;
            }];
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMViewChannelsRequestSucceeded)];
        });
        
        it(@"should fail to subscribe a device to a non-existant channel", ^{
            __block CMChannelResponse *res = nil;
            // No way to create channels without REST API
            [service subscribeThisDeviceToPushChannel:@"random_channel" callback:^(CMChannelResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMDeviceChannelOperationFailed)];
        });
        
        it(@"should subscribe a device to a channel", ^{
            __block CMChannelResponse *res = nil;
            [service subscribeThisDeviceToPushChannel:channelName callback:^(CMChannelResponse *response) {
                NSLog(@"Body: %@", response.body);
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMDeviceAddedToChannel)];
        });
        
        it(@"should subscribe another device to a channel", ^{
            __block CMChannelResponse *res = nil;
            [service subscribeDevice:@"device" toPushChannel:channelName callback:^(CMChannelResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMDeviceAddedToChannel)]; //no device so it fails
        });
        
        it(@"should subscribe a user to a channel", ^{
            __block CMChannelResponse *res = nil;
            // No way to create channels without REST API
            [service subscribeUser:user toPushChannel:channelName callback:^(CMChannelResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMDeviceAddedToChannel)];
        });
        
        it(@"should unsubscribe this device from a channel", ^{
            __block CMChannelResponse *res = nil;
            // No way to create channels without REST API
            [service unSubscribeThisDeviceFromPushChannel:channelName callback:^(CMChannelResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMDeviceRemovedFromChannel)];
        });
        
        it(@"should unsubscribe another device from a channel", ^{
            __block CMChannelResponse *res = nil;
            // No way to create channels without REST API
            [service unSubscribeDevice:@"device" fromPushChannel:channelName callback:^(CMChannelResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMDeviceRemovedFromChannel)];
        });
        
        it(@"should unsubscribe a user from a channel", ^{
            __block CMChannelResponse *res = nil;
            // No way to create channels without REST API
            [service unSubscribeUser:user fromPushChannel:channelName callback:^(CMChannelResponse *response) {
                res = response;
            }];
            
            [[expectFutureValue(res) shouldEventually] beNonNil];
            [[expectFutureValue( theValue(res.result) ) shouldEventually] equal:@(CMDeviceRemovedFromChannel)];
        });
        
        it(@"should let the user unregister a token", ^{
            
            __block CMDeviceTokenResult res = NSNotFound;
            [service unRegisterForPushNotificationsWithUser:user callback:^(CMDeviceTokenResult result) {
                res = result;
            }];
            
            [[expectFutureValue(theValue(res)) shouldEventually] equal:@(CMDeviceTokenDeleted)];
        });
        
    });
    
});

SPEC_END
