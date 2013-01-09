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
#import "CMObjectDecoder.h"

@interface CMUser (Internal)
+ (NSURL *)cacheLocation;
@end

@interface CustomUser : CMUser
@property (strong) NSString *name;
@property (assign) int age;
@end

@implementation CustomUser
@synthesize name, age;

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.age] forKey:@"age"];
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.age = [[aDecoder decodeObjectForKey:@"age"] intValue];
    }
    
    return self;
}


@end

SPEC_BEGIN(CMUserSpec)

describe(@"CMUser", ^{
    [[CMAPICredentials sharedInstance] setAppSecret:@"appSecret"];
    [[CMAPICredentials sharedInstance] setAppIdentifier:@"appIdentifier"];
    
    context(@"given a user", ^{
        it(@"should set the userId when setting email", ^{
            CMUser *user = [[CMUser alloc] init];
            
            [user.email shouldBeNil];
            user.email = @"test@testing.com";
            [[user.email should] equal:@"test@testing.com"];
        });
    });

    context(@"given a username and password", ^{
        it(@"should record both in memory and return them when the getters are accessed", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"someone@domain.com" andPassword:@"pass"];
            [[user.email should] equal:@"someone@domain.com"];
            [[user.password should] equal:@"pass"];
            [user.token shouldBeNil];
        });
    });


    context(@"given a session token", ^{
        it(@"should no longer maintain a copy of the password", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"someone@domain.com" andPassword:@"pass"];
            user.token = @"token";

            [[user.email should] equal:@"someone@domain.com"];
            [user.password shouldBeNil];
            [[user.token should] equal:@"token"];
        });
    });

    context(@"given a clean instance of a CMUser subclass", ^{
        __block CustomUser *user = nil;
        __block KWMock *mockWebService = nil;

        beforeEach(^{
            user = [[CustomUser alloc] initWithEmail:@"marc@cloudmine.me" andPassword:@"pass"];
            mockWebService = [CMWebService nullMock];
            [user setValue:mockWebService forKey:@"webService"];

            // Setting these two values should not make the object dirty because it hasn't been persisted remotely yet.
            user.name = @"Marc";
            user.age = 24;
        });

        it(@"should not be dirty", ^{
            [[theValue(user.isDirty) should] beNo];
        });
        
        context(@"when accessing other users of the app", ^{
            beforeEach(^{
                [user setValue:@"abc123" forKey:@"objectId"];
            });
            
            it(@"should cache the user returned when searching by a specific identifier", ^{
                [[NSFileManager defaultManager] removeItemAtURL:[CMUser cacheLocation] error:nil];
                
                KWCaptureSpy *callbackBlockSpy = [mockWebService captureArgument:@selector(getUserProfileWithIdentifier:callback:) atIndex:1];
                [[mockWebService should] receive:@selector(getUserProfileWithIdentifier:callback:) withCount:1];
                [[CMUser should] receive:@selector(cacheMultipleUsers:) withCount:1];
                
                // This first call should trigger the web service call.
                [CMUser userWithIdentifier:user.objectId callback:^(NSArray *users, NSDictionary *errors) {
                    [[[[users lastObject] objectId] should] equal:user.objectId];
                }];
                
                CMWebServiceUserFetchSuccessCallback callback = callbackBlockSpy.argument;
                NSDictionary *userState = [CMObjectEncoder encodeObjects:$set(user)];
                callback(userState, [NSDictionary dictionary], $num(1));
                
                // Now let's do the same thing again, but this time it should read from the cache.
                [[CMUser should] receive:@selector(userFromCacheWithIdentifier:) withArguments:user.objectId];
                [CMUser userWithIdentifier:user.objectId callback:^(NSArray *users, NSDictionary *errors) {
                    [[[[users lastObject] objectId] should] equal:user.objectId];
                    [[[[users lastObject] email] should] equal:user.email];
                }];
            });
        });
        
        context(@"when making changes to fields on the instance", ^{
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
            
            it(@"should not crash when the properties returned are named differently than the properties defined in the object", ^{
                // Make the user appear to exist server side.
                [user setValue:@"1234" forKey:@"objectId"];
                
                // Verify that the user is not dirty.
                [[theValue(user.isDirty) should] beNo];
                
                // Set up the capture spy to intercept the callback block.
                KWCaptureSpy *callbackBlockSpy = [mockWebService captureArgument:@selector(saveUser:callback:) atIndex:1];
                [[mockWebService should] receive:@selector(saveUser:callback:)];
                
                // Run the test method.
                // Saving the object should force the person to update, and we can check to see if the properties are set properly
                [user save:nil];
                
                // Make a mock response from the web server with changes we haven't seen yet.
                NSDictionary *parsedResults = @{@"__class__" : @"CustomUser", @"__id__" : @"1234", @"__type__" : @"user", @"name" : @"Tomas", @"ageOfPerson" : @35, @"newField" : @"aValue"};
                
                
                CMWebServiceUserAccountOperationCallback callback = callbackBlockSpy.argument;
                callback(CMUserAccountProfileUpdateSucceeded, parsedResults);
                
                // Validate that the values from the server were applied to the user correctly.
                // Will be updated, because the name is the same on server and property
                [[user.name should] equal:@"Tomas"];
                // Will NOT be updated, because the naming is different.
                [[theValue(user.age) shouldNot] equal:theValue(35)];
            });
            
            it(@"should encode and decode nil properly", ^{
                [user setValue:@"1234" forKey:@"objectId"];
                user.name = nil;
                user.age = 0;
        
                NSDictionary *serializedUser = [CMObjectEncoder encodeObjects:$set(user)];
                NSDictionary *theUser = [serializedUser objectForKey:user.objectId];
                
                [[[theUser valueForKey:@"name"] should] beIdenticalTo:[NSNull null]];
                [[[theUser valueForKey:@"age"] should] equal:theValue(0)];
                
                CustomUser *customUser = [[CMObjectDecoder decodeObjects:serializedUser] lastObject];
                [customUser.name shouldBeNil];
                [[theValue(customUser.age) should] equal:theValue(0)];
                
            });
            
            it(@"should encode and decode null properly", ^{
                [user setValue:@"1234" forKey:@"objectId"];
                user.name = NULL;
                
                NSDictionary *serializedUser = [CMObjectEncoder encodeObjects:$set(user)];
                NSDictionary *theUser = [serializedUser objectForKey:user.objectId];
                NSLog(@"Result: %@", serializedUser);
                
                [[[theUser valueForKey:@"name"] should] beIdenticalTo:[NSNull null]];
                
                CustomUser *customUser = [[CMObjectDecoder decodeObjects:serializedUser] lastObject];
                [customUser.name shouldBeNil];
            });
            
        });
    });
});

SPEC_END
