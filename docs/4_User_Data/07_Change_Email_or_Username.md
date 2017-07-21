#Change Email or Username

If a user wishes to change their email or username they can do so as long as they know their current password. To change a user's Email:

```objc
CMUser *user = [[CMUser alloc] initWithEmail:@"test@example.com" andPassword:@"my-password"];
 
[self.user changeEmailTo:@"newTest@example.com" password:@"my-password" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
  switch (resultCode) {
    case CMUserAccountEmailChangeSucceeded:
      // Success! You should resave the local user now.
      break;
    case CMUserAccountCredentialChangeFailedDuplicateEmail:
      // This email is already in use
      break;
    case CMUserAccountUnknownResult:
      // An error occurred
      break;
    default:
      break;
  }
}];
```

Changing the username is similar.

```objc
CMUser *user = [[CMUser alloc] initWithUsername:@"My Username" andPassword:@"my-password"];
 
[self.user changeUsernameTo:@"A Better Username" password:@"my-password" callback:^(CMUserAccountResult resultCode, NSArray *messages) {
  switch (resultCode) {
    case CMUserAccountUsernameChangeSucceeded:
      // Success! You should resave the local user now.
      break;
    case CMUserAccountCredentialChangeFailedDuplicateUsername:
      // This userbane is already in use
      break;
    case CMUserAccountUnknownResult:
      // An error occurred
      break;
    default:
      break;
  }
}];
```

If you want to change more than one at once there is another method.

```objc
[self.user changeUserCredentialsWithPassword:@"my-password"
                                 newPassword:@"my-new-password"
                                 newUsername:@"The Best Username"
                                   newEmail:@"testing123@example.com"
                                    callback:^(CMUserAccountResult resultCode, NSArray *messages) {
                                      switch (resultCode) {
                                          case CMUserAccountCredentialChangeSucceeded:
                                              // Success! You should resave your user locally now.
                                              break;
                                          case CMUserAccountCredentialChangeFailedDuplicateInfo:
                                              // The email or username is already in use
                                              break;
                                          case CMUserAccountCredentialChangeFailedInvalidCredentials:
                                              // The user's Password was incorrect
                                              break;n
                                          case CMUserAccountUnknownResult:
                                              // An error occurred
                                              break;
                                          default:
                                              break;
                                      }
                                  }];
```

When changing more than one property of the user you may pass nil as any parameter except password.
