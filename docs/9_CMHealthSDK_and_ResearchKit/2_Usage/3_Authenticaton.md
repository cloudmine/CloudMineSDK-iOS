# Authentication

The SDK provides a user abstraction for managing your participant accounts, with straightforward
methods for user authentication.

```Objective-C
#import <CMHealth/CMHealth.h>

[[CMHUser currentUser] signUpWithEmail:email password:password andCompletion:^(NSError *error) {
    if (nil != error) {
        // handle error
        return;
    }

    // The user is now signed up
}];
```

The SDK also provides [preconfigured screens](#authentication-screens)
for participant authentication.

## Authentication Screens

For convenience, the SDK provides preconfigured view controllers for user sign up and login.
These screens can be presented modally and handle the collection and validation of user
email and password. Data is returned via delegation.

![Login Screenshot](img/CMHealth-SDK-Login-Screen.png)

```Objective-C
#import "MyViewController.h"
#import <CMHealth/CMHealth.h>

@interface MyViewController () <CMHAuthViewDelegate>
@end

@implementation MyViewController
- (IBAction)loginButtonDidPress:(UIButton *)sender
{
    CMHAuthViewController *loginViewController = [CMHAuthViewController loginViewController];
    loginViewController.delegate = self;
    [self presentViewController:loginViewController animated:YES completion:nil];
}

#pragma mark CMHAuthViewDelegate

- (void)authViewCancelledType:(CMHAuthType)authType
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)authViewOfType:(CMHAuthType)authType didSubmitWithEmail:(NSString *)email andPassword:(NSString *)password
{
    [self dismissViewControllerAnimated:YES completion:nil];

    switch (authType) {
        case CMHAuthTypeLogin:
            [self loginWithEmail:email andPassword:password];
            break;
        case CMHAuthTypeSignup:
            [self signupWithEmail:email andPassword:password];
            break;
        default:
            break;
    }
}

#pragma mark Private

- (void)signupWithEmail:(NSString *)email andPassword:(NSString *)password
{
    // Sign user up
}

- (void)loginWithEmail:(NSString *)email andPassword:(NSString *a)password
{
    // Log user in
}

@end
```
