# User Logout

Once a user has been logged in, their session token can be invalidated by logging out the user.

```objc
[user logoutWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
    switch(resultCode) {
    case CMUserAccountLogoutSucceeded:
        // success! the user is logged out
        break;
    case CMUserAccountLogoutFailedUnknownAccount:
        // failed, the session token didn't correspond to any user
        break;
    }
}];
```

