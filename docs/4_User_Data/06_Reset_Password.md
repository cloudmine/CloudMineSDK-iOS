#Reset User Password

If a user forgets their password, you can email them a link to reset it using the CMUser.resetForgottenPasswordWithCallback method. The user will be responsible for clicking on the email link and providing the new password.

```objc
CMUser *user = [[CMUser alloc] initWithEmail:@"test@example.com" andPassword:@""];
 
[user resetForgottenPasswordWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
    switch(resultCode) {
    case CMUserAccountPasswordResetEmailSent:
        // sent the user their reset email, it's up to them now
        break;
    case CMUserAccountOperationFailedUnknownAccount:
        // account doesn't exist
        break;
    }
}];
```
	
