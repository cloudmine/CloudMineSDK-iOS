//
//  UIImageWithCloudMineIntegrationSpec.m
//  cloudmine-ios
//
//  Created by Ethan Mick on 6/11/14.
//  Copyright (c) 2016 CloudMine, Inc. All rights reserved.
//

#import "Kiwi.h"
#import "CMStore.h"
#import "CMAPICredentials.h"
#import "UIImageView+CloudMine.h"
#import "CMWebService.h"
#import "CMTestMacros.h"

SPEC_BEGIN(UIImageWithCloudMineIntegrationSpec)

describe(@"UIImageWithCloudMineIntegrationSpec", ^{
    
    __block CMStore *store = nil;
    __block NSString *key = nil;
    __block UIImage *image = nil;
    
    beforeAll(^{
        [[CMAPICredentials sharedInstance] setAppIdentifier:APP_ID];
        [[CMAPICredentials sharedInstance] setApiKey:API_KEY];
        [[CMAPICredentials sharedInstance] setBaseURL:BASE_URL];
        
        [[CMStore defaultStore] setWebService:[[CMWebService alloc] init]];
        store = [CMStore store];
        
        //send image to CloudMine
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:path];
        
        __block CMFileUploadResponse *resp = nil;
        [store saveFileWithData:UIImagePNGRepresentation(image) additionalOptions:nil callback:^(CMFileUploadResponse *response) {
            resp = response;
            key = resp.key;
            NSLog(@"Key? %@", key);
        }];
        
        [[expectFutureValue(resp) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        [[expectFutureValue(theValue(resp.result)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:theValue(CMFileCreated)];
        [[expectFutureValue(key) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
        
        __block CMFileUploadResponse *resp2 = nil;
        [store saveFileWithData:UIImagePNGRepresentation(image) named:@"second" additionalOptions:nil callback:^(CMFileUploadResponse *response) {
            resp2 = response;
        }];
        [[expectFutureValue(resp2) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] beNonNil];
    });
    
    it(@"should be able to set the image to a UIImageView with just the key", ^{
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [imageView setImageWithFileKey:key];
        [[expectFutureValue(UIImagePNGRepresentation(imageView.image)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:UIImagePNGRepresentation(image)];
    });
    
    it(@"should immediatly set a placeholder iamge", ^{
        //send image to CloudMine
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mobile" ofType:@"png"];
        UIImage *placeholder = [UIImage imageWithContentsOfFile:path];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [imageView setImageWithFileKey:@"second" placeholderImage:placeholder];
        [[imageView.image shouldNot] beNil];
        [[UIImagePNGRepresentation(imageView.image) should] equal:UIImagePNGRepresentation(placeholder)];
        [[expectFutureValue(UIImagePNGRepresentation(imageView.image)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:UIImagePNGRepresentation(image)];
    });
    
    it(@"should cache the image we retrived and use it immediatly", ^{
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [imageView setImageWithFileKey:key];
        [[UIImagePNGRepresentation(imageView.image) should] equal:UIImagePNGRepresentation(image)];
    });
    
    it(@"should search a user's files if passed a user", ^{
        
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"cloudmine" ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:path];
        
        __block CMFileUploadResponse *resp = nil;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        CMUser *user = [[CMUser alloc] initWithEmail:@"testUserImage@test.com" andPassword:@"testing"];
        [user createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
            
            [[CMStore defaultStore] setUser:user];
            [[CMStore defaultStore] saveUserFileWithData:UIImagePNGRepresentation(image) additionalOptions:nil callback:^(CMFileUploadResponse *response) {
                resp = response;
                key = resp.key;
                [imageView setImageWithFileKey:key placeholderImage:nil user:user];
            }];
        }];
        
        [[expectFutureValue(UIImagePNGRepresentation(imageView.image)) shouldEventuallyBeforeTimingOutAfter(CM_TEST_TIMEOUT)] equal:UIImagePNGRepresentation(image)];
    });
    
});

SPEC_END
