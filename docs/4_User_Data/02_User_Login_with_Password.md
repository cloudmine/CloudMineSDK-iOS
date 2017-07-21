# User Login with Password

Once we have an instance of a user, and that instance has been created server-side, we can log in as that user. This will give us a CMSessionToken if the e-mail and password were correct. If you created the user with a username and not email, you should use that to login with.

This request clears the password field on the user regardless of whether or not login was successful. A new session token is generated every time a user logs in, and remains valid for up to 6 months of inactivity.

```objc 
CMUser *user = [[CMUser alloc] initWithEmail:@"test@example.com" andPassword:@"my-password"];
// Or create the user with a username
CMUser *anotherUser = [[CMUser alloc] initWithUsername:@"My Username" andPassword:@"my-password"];
 
// You can use "anotherUser" here in the same way!
[user loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
    switch(resultCode) {
    case CMUserAccountLoginSucceeded:
    {    // success! the user now has a session token
         NSString *token = user.token;
         break;
    }
    case CMUserAccountLoginFailedIncorrectCredentials:
        // the users credentials were invalid
        break;
    case CMUserAccountOperationFailedUnknownAccount:
        // this account doesn't exist
        break;
    }
}];
 
// Set the user property on CMStore. This user will be used for all user-level calls from this point on.
store.user = user;
```

In this example `anotherUser` can be used in the exact same way as `user`. The login method will default to the email, and if not present it will use the username. This CMStore can now be used for user-level operations.

### Current User

`CMUser` has a convenience class method called `currentUser`, which will return the currently logged in user, if there is one. It will only return the most recent logged in user, so if your application has more than one logged in user you will have to manage them yourself.

`[CMUser currentUser]` is set after the user has logged in. It serializes the user and saves it using `[NSUserDefaults standardUserDefaults]`, which will persist the user between app launches. The user will stay saved until `logout:` is called.

```objc
// After a login
CMUser *user = [CMUser currentUser];
```

You can use this throughout your application as an easy way to get a reference to the current user.


