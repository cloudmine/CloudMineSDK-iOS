//
//  CMUserSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"
#import "SPLowVerbosity.h"

#import "CMUser.h"
#import "CMWebService.h"
#import "CMAPICredentials.h"
#import "CMObjectEncoder.h"

@interface CustomUser : CMUser
@property (strong) NSString *name;
@property (assign) int age;
@end

@implementation CustomUser
@synthesize name, age;
@end

SPEC_BEGIN(CMUserSpec)

describe(@"CMUser", ^{
    [[CMAPICredentials sharedInstance] setAppSecret:@"appSecret"];
    [[CMAPICredentials sharedInstance] setAppIdentifier:@"appIdentifier"];

    context(@"given a username and password", ^{
        it(@"should record both in memory and return them when the getters are accessed", ^{
            CMUser *user = [[CMUser alloc] initWithUserId:@"someone@domain.com" andPassword:@"pass"];
            [[user.userId should] equal:@"someone@domain.com"];
            [[user.password should] equal:@"pass"];
            [user.token shouldBeNil];
        });
    });

    context(@"given a session token", ^{
        it(@"should no longer maintain a copy of the password", ^{
            CMUser *user = [[CMUser alloc] initWithUserId:@"someone@domain.com" andPassword:@"pass"];
            user.token = @"token";

            [[user.userId should] equal:@"someone@domain.com"];
            [user.password shouldBeNil];
            [[user.token should] equal:@"token"];
        });
    });

    context(@"given a clean instance of a CMUser subclass", ^{
        __block CustomUser *user = nil;
        __block KWMock *mockWebService = nil;

        beforeEach(^{
            user = [[CustomUser alloc] initWithUserId:@"marc@cloudmine.me" andPassword:@"pass"];
            mockWebService = [CMWebService nullMock];
            [user setValue:mockWebService forKey:@"webService"];

            // Setting these two values should not make the object dirty because it hasn't been persisted remotely yet.
            user.name = @"Marc";
            user.age = 24;
        });

        it(@"should not be dirty", ^{
            [[theValue(user.isDirty) should] beNo];
        });

        it(@"should become dirty if properties are changed after a save and no other object changes have occured server-side", ^{
            KWCaptureSpy *callbackBlockSpy = [mockWebService captureArgument:@selector(saveUser:callback:) atIndex:1];
            [[mockWebService should] receive:@selector(saveUser:callback:)];

            [user save:^(CMUserAccountResult resultCode, NSArray *messages) {
                [user setValue:@"1234" forKey:@"objectId"]; // need to do this so it thinks it has actually been saved remotely
            }];

            CMWebServiceUserAccountOperationCallback callback = callbackBlockSpy.argument;
            NSDictionary *userState = [[CMObjectEncoder encodeObjects:$set(user)] objectForKey:user.objectId];
            callback(CMUserAccountProfileUpdateSucceeded, userState);

            // Object has just been saved, so it should not be dirty.
            [[theValue(user.isDirty) should] beNo];

            // Make a change to the object.
            user.name = @"Derek";

            // It should be dirty.
            [[theValue(user.isDirty) should] beYes];
        });

        it(@"should use server state locally after login if there were no local changes made before login", ^{
            // Make the user appear to exist server side.
            [user setValue:@"1234" forKey:@"objectId"];

            // Verify that the user is still not dirty.
            [[theValue(user.isDirty) should] beNo];

            // Set up the capture spy to intercept the callback block.
            KWCaptureSpy *callbackBlockSpy = [mockWebService captureArgument:@selector(loginUser:callback:) atIndex:1];
            [[mockWebService should] receive:@selector(loginUser:callback:)];

            // Run the test method.
            [user loginWithCallback:nil];

            // Make a mock response from the web server with changes we haven't seen yet.
            NSMutableDictionary *userState = $mdict(@"session_token", @"5555", @"expires", @"Mon 01 Jun 2020 01:00:00 GMT", @"profile", $dict(@"name", @"Philip", @"age", $num(30)));

            CMWebServiceUserAccountOperationCallback callback = callbackBlockSpy.argument;
            callback(CMUserAccountLoginSucceeded, userState);

            // Validate that the values from the server were applied to the user.
            [[user.name should] equal:@"Philip"];
            [[theValue(user.age) should] equal:theValue(30)];
            [[user.token should] equal:@"5555"];
        });

        it(@"should ignore server state locally after login if there were local changes made before login", ^{
            // Make the user appear to exist server side.
            [user setValue:@"1234" forKey:@"objectId"];
            user.name = @"Conrad";
            user.age = 15;

            // Verify that the user is now dirty.
            [[theValue(user.isDirty) should] beYes];

            // Set up the capture spy to intercept the callback block.
            KWCaptureSpy *callbackBlockSpy = [mockWebService captureArgument:@selector(loginUser:callback:) atIndex:1];
            [[mockWebService should] receive:@selector(loginUser:callback:)];

            // Run the test method.
            [user loginWithCallback:nil];

            // Make a mock response from the web server with changes we haven't seen yet.
            NSMutableDictionary *userState = $mdict(@"session_token", @"5555", @"expires", @"Mon 01 Jun 2020 01:00:00 GMT", @"profile", $dict(@"name", @"Philip", @"age", $num(30)));

            CMWebServiceUserAccountOperationCallback callback = callbackBlockSpy.argument;
            callback(CMUserAccountLoginSucceeded, userState);

            // Validate that the values from the server were not applied.
            [[user.name should] equal:@"Conrad"];
            [[theValue(user.age) should] equal:theValue(15)];
            [[user.token should] equal:@"5555"];
        });
    });
});

SPEC_END
