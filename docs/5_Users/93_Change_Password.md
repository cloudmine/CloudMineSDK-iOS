#Change User Password

If a user wishes to change their password and still know their current password, you can change it by using the CMUser.changePasswordTo method.

If the user does not know their current password, use the password reset functionality instead.

```objc
CMUser *user = [[CMUser alloc] initWithEmail:@"test@example.com" andPassword:@"my-password"];
 
[user changePasswordTo:@"new-password"
                  from:@"old-password"
              callback:^(CMUserAccountResult resultCode, NSArray *messages) {
    switch(resultCode) {
    case CMUserAccountPasswordChangeSucceeded:
        // success!
        break;
    case CMUserAccountPasswordChangeFailedInvalidCredentials:
        // the users credentials were invalid
        break;
    case CMUserAccountOperationFailedUnknownAccount:
        // this account doesn't exist
        break;
    }
}];
```
{{note "When a user's password is changed, all session tokens are invalidated due to security concerns. Existing sessions will need to be re-authenticated."}}