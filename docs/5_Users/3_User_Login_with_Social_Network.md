# User Login with Social Network

{{note 'You will need to configure each social network you plan on using in your app using each network\'s website.'}}

In addition to logging in as a CloudMine user with an email address and password, you can also allow your users to login via a social network such as Facebook or Twitter. This can either be the primary way a user logs into your application, or a user may link their existing CloudMine user account to a social service. Either way, a CMUser is returned, which contains the user's profile, and has the session token already set. The Services array will also be populated by the different networks this account has been linked to.

First let's look at logging in using social, without having an existing `CMUser`. The call to `loginWithSocialNetwork` will pop up a UIWebView, which will begin the authentication process. A login web page will be displayed, and once they enter correct credentials the callback will be executed.

```objc
CMUser *user = [[CMUser alloc] init];
 
[user loginWithSocialNetwork:CMSocialNetworkFacebook viewController:self params:nil callback:^(CMUserAccountResult resultCode, NSArray *messages) {
   if (resultCode == CMUserAccountLoginSucceeded) {
      //Logged in!
      NSString *token = user.token;
  } else {
      //Look up and deal with error
      NSLog(@"Message? %@", messages);
  }
 
}];
 
// Set the user property on CMStore. This user will be used for all user-level calls from this point on.
store.user = user;
```

A similar example with Google+

```objc
CMUser *user = [[CMUser alloc] init];
 
[user loginWithSocialNetwork:CMSocialNetworkGoogle viewController:self params:nil callback:^(CMUserAccountResult resultCode, NSArray *messages) {
   if (resultCode == CMUserAccountLoginSucceeded) {
      //Logged in!
      NSString *token = user.token;
  } else {
      //Look up and deal with error
      NSLog(@"Message? %@", messages);
  }
 
}];
 
// Set the user property on CMStore. This user will be used for all user-level calls from this point on.
store.user = user;
```

You can also link an existing user to a social service. Once this is done, the user can login either through their `CMUser` credentials or through a linked social site. This linking process requires the `CMUser` to be logged in; if the request is made with a `CMUser` who is not logged in, the call will instead create a new user account.

```objc 
CMUser *user = [[CMUser alloc] initWithEmail:@"test@example.com" andPassword:@"my-password"];
 
[user createAccountAndLoginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
  switch(resultCode) {
    case CMUserAccountCreateSucceeded:
      // Created account, now let's link!
      [user loginWithSocialNetwork:CMSocialNetworkFacebook viewController:self params:nil callback:^(CMUserAccountResult resultCode, NSArray *messages) {
        if (resultCode == CMUserAccountLoginSucceeded) {
          //Linked Account!
          NSString *token = user.token;
        } else {
          //Look up and deal with error
          NSLog(@"Message? %@", messages);
         }
       }];
 
       break;
    case CMUserAccountCreateFailedInvalidRequest:
      // forgot the email or password
      break;
    case CMUserAccountCreateFailedDuplicateAccount:
      // account with this email already exists
      break;
    }
}];
```

The same rules for token inactivity and `[CMUser currentUser]` apply as they do for [login with a password](#/ios#user-login-with-password).
