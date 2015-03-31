# Create User

You can create a new user by instantiating a new CMUser object and calling createAccountWithCallback on it. A CMUser may be instantiated with either a unique username, email, or both.

```objc
CMUser *user1 = [[CMUser alloc] initWithUsername:@"A Username" andPassword@"my-password"];       
CMUser *user2 = [[CMUser alloc] initWithEmail:@"test@example.com" andPassword:@"my-password"];
CMUser *user3 = [[CMUser alloc] initWithEmail:@"anEmail@test.com" andUsername:@"Your Name" andPassword:@"my-password"];
```

Any of these three methods will properly create the CMUser. Once you have the user, you need to create it on the server.

```objc
[user createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
    switch(resultCode) {
        case CMUserAccountCreateSucceeded:
            // did it!
            break;
        case CMUserAccountCreateFailedInvalidRequest:
            // forgot the email/username or password
            break;
        case CMUserAccountCreateFailedDuplicateAccount:
            // account with this email already exists
            break;
    }
}];
```
