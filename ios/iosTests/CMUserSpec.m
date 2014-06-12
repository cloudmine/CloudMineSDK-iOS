//
//  CMUserSpec.m
//  cloudmine-iosTests
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "Kiwi.h"
#import "CMUser.h"
#import "CMWebService.h"
#import "CMAPICredentials.h"
#import "CMObjectEncoder.h"
#import "CMObjectDecoder.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

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
        
        context(@"deprecated methods", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            it(@"should make the userId the email", ^{
                NSString *email = @"testing@test.com";
                CMUser *user = [[CMUser alloc] initWithUserId:email andPassword:@"testing"];
                [[user.email should] equal:email];
                [[user.userId should] equal:email];
                [[user.username should] beNil];
            });
            
            it(@"should make the userid an email with a username too", ^{
                NSString *email = @"testing@test.com";
                NSString *username = @"ausername";
                CMUser *user = [[CMUser alloc] initWithUserId:email andUsername:username andPassword:@"testing"];
                [[user.email should] equal:email];
                [[user.userId should] equal:email];
                [[user.username should] equal:username];
            });
            
            it(@"should let you set the userid and change the email", ^{
                NSString *email = @"testing@test.com";
                CMUser *user = [[CMUser alloc] initWithUserId:email andPassword:@"testing"];
                [[user.email should] equal:email];
                NSString *newEmail = @"somethingelse@test.com";
                [user setUserId:newEmail];
                [[user.email should] equal:newEmail];
            });
            
            
#pragma clang diagnostic pop
        });
        
    });

    context(@"given a username and password", ^{
        it(@"should record both in memory and return them when the getters are accessed", ^{
            CMUser *user = [[CMUser alloc] initWithEmail:@"someone@domain.com" andPassword:@"pass"];
            [[user.email should] equal:@"someone@domain.com"];
            [[user.password should] equal:@"pass"];
            [user.token shouldBeNil];
        });
        
        it(@"should know if two users are equal", ^{
           CMUser *user1 = [[CMUser alloc] initWithEmail:@"someone@domain.com" andPassword:@"pass"];
           CMUser *user2 = [[CMUser alloc] initWithEmail:@"someone@domain.com" andPassword:@"pass"];
            [[user1 should] equal:user2];
        });
        
        it(@"should know if two users are equal with usernames", ^{
            CMUser *user1 = [[CMUser alloc] initWithUsername:@"someone" andPassword:@"pass"];
            CMUser *user2 = [[CMUser alloc] initWithUsername:@"someone" andPassword:@"pass"];
            [[user1 should] equal:user2];
        });
        
        it(@"should know if two users are not equal with different passwords", ^{
            CMUser *user1 = [[CMUser alloc] initWithEmail:@"someone@domain.com" andPassword:@"pass1"];
            CMUser *user2 = [[CMUser alloc] initWithEmail:@"someone@domain.com" andPassword:@"pass2"];
            [[user1 shouldNot] equal:user2];
            
            user1 = [[CMUser alloc] initWithUsername:@"someone" andPassword:@"pass1"];
            user2 = [[CMUser alloc] initWithUsername:@"someone" andPassword:@"pass2"];
            [[user1 shouldNot] equal:user2];
        });
        
        it(@"should know an object is not equal to a CMUser", ^{
            CMUser *user1 = [[CMUser alloc] initWithEmail:@"someone@domain.com" andPassword:@"pass"];
            NSObject *object = [NSObject new];
            [[user1 shouldNot] equal:object];
        });
        
        it(@"should know that two users are equal with their tokens", ^{
            CMUser *user1 = [[CMUser alloc] init]; user1.token = @"123";
            CMUser *user2 = [[CMUser alloc] init]; user2.token = @"123";
            [[user1 should] equal:user2];
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
        
        it(@"should logout properly", ^{
            user.token = @"1234";
            user.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:1000];
            
            KWCaptureSpy *callbackBlockSpy = [[user valueForKey:@"webService"] captureArgument:@selector(logoutUser:callback:) atIndex:1];
            [[[user valueForKey:@"webService"] should] receive:@selector(logoutUser:callback:) withCount:1];
            
            // This first call should trigger the web service call.
            [user logoutWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                [[theValue(resultCode) should] equal:@(CMUserAccountLogoutSucceeded)];
            }];
            
            void (^callback)(CMUserAccountResult result, NSDictionary *messages) = callbackBlockSpy.argument;
            callback(CMUserAccountLogoutSucceeded, @{});
            
            [[user.token should] beNil];
            [[user.tokenExpiration should] beNil];
        });
        
        context(@"when accessing other users of the app", ^{
            beforeEach(^{
                [user setValue:@"abc123" forKey:@"objectId"];
            });
            
            it(@"should cache the user returned when searching by a specific identifier", ^{
                [[NSFileManager defaultManager] removeItemAtURL:[CMUser cacheLocation] error:nil];
                
                KWCaptureSpy *callbackBlockSpy = [[CMWebService sharedWebService] captureArgument:@selector(getUserProfileWithIdentifier:callback:) atIndex:1];
                [[[CMWebService sharedWebService] should] receive:@selector(getUserProfileWithIdentifier:callback:) withCount:2];
                [[CMUser should] receive:@selector(cacheMultipleUsers:) withCount:1];
                
                // This first call should trigger the web service call.
                [CMUser userWithIdentifier:user.objectId callback:^(NSArray *users, NSDictionary *errors) {
                    [[[[users lastObject] objectId] should] equal:user.objectId];
                }];
                
                CMWebServiceUserFetchSuccessCallback callback = callbackBlockSpy.argument;
                NSDictionary *userState = [CMObjectEncoder encodeObjects:[NSSet setWithObject:user]];
                callback(userState, [NSDictionary dictionary], @1);
                
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
                NSDictionary *userState = [[CMObjectEncoder encodeObjects:[NSSet setWithObject:user]] objectForKey:user.objectId];
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
                NSMutableDictionary *userState = [NSMutableDictionary dictionaryWithDictionary:@{@"session_token": @"5555",
                                                                                                 @"expires": @"Mon 01 Jun 2020 01:00:00 GMT",
                                                                                                 @"profile": @{@"name": @"Philip", @"age": @30}}];
                
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
                NSMutableDictionary *userState = [NSMutableDictionary dictionaryWithDictionary:@{@"session_token": @"5555",
                                                                                                 @"expires": @"Mon 01 Jun 2020 01:00:00 GMT",
                                                                                                 @"profile": @{@"name": @"Philip", @"age": @30}}];
                
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
        
                NSDictionary *serializedUser = [CMObjectEncoder encodeObjects:[NSSet setWithObject:user]];
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
                
                NSDictionary *serializedUser = [CMObjectEncoder encodeObjects:[NSSet setWithObject:user]];
                NSDictionary *theUser = [serializedUser objectForKey:user.objectId];
                
                [[[theUser valueForKey:@"name"] should] beIdenticalTo:[NSNull null]];
                
                CustomUser *customUser = [[CMObjectDecoder decodeObjects:serializedUser] lastObject];
                [customUser.name shouldBeNil];
            });
            
            it(@"should encode the username properly", ^{
                user.username = @"aUsername";
                NSDictionary *serializedUser = [CMObjectEncoder encodeObjects:[NSSet setWithObject:user]];
                NSDictionary *theUser = [serializedUser objectForKey:user.objectId];
                [[theUser[@"username"] should] equal:@"aUsername"];
            });
        });
    });
    
    context(@"given a CMUser operation code", ^{
        it(@"should be properly return true or false", ^{
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountUnknownResult)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountLoginSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountLogoutSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCreateSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountProfileUpdateSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountPasswordChangeSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountEmailChangeSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountUsernameChangeSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCredentialChangeSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountPasswordResetEmailSent)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCredentialChangeFailedDuplicateEmail)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCredentialChangeFailedInvalidCredentials)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCreateFailedInvalidRequest)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountProfileUpdateFailed)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCreateFailedDuplicateAccount)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCredentialChangeFailedDuplicateUsername)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCredentialChangeFailedDuplicateInfo)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountLoginFailedIncorrectCredentials)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountPasswordChangeFailedInvalidCredentials)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountSocialLoginErrorOccurred)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountSocialLoginDismissed)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountOperationFailedUnknownAccount)) should] equal:theValue(NO)];
            
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountUserIdChangeSucceeded)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationSuccessful(CMUserAccountCredentialChangeFailedDuplicateUserId)) should] equal:theValue(NO)];
#pragma clang diagnostic pop
        });
        
        it(@"should be an properly work with the fail command", ^{
            [[theValue(CMUserAccountOperationFailed(CMUserAccountUnknownResult)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountLoginSucceeded)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountLogoutSucceeded)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountCreateSucceeded)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountProfileUpdateSucceeded)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountPasswordChangeSucceeded)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountEmailChangeSucceeded)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountUsernameChangeSucceeded)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountCredentialChangeSucceeded)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountPasswordResetEmailSent)) should] equal:theValue(NO)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountCredentialChangeFailedDuplicateEmail)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountCredentialChangeFailedInvalidCredentials)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountCreateFailedInvalidRequest)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountProfileUpdateFailed)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountCreateFailedDuplicateAccount)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountCredentialChangeFailedDuplicateUsername)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountCredentialChangeFailedDuplicateInfo)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountLoginFailedIncorrectCredentials)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountPasswordChangeFailedInvalidCredentials)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountSocialLoginErrorOccurred)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountSocialLoginDismissed)) should] equal:theValue(YES)];
            [[theValue(CMUserAccountOperationFailed(CMUserAccountOperationFailedUnknownAccount)) should] equal:theValue(YES)];
            
            
        });
        
    });
    
});


SPEC_END
