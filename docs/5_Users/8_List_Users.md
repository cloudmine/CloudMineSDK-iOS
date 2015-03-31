# List Users in Application

Since every user has a public profile, you can load all the users of your app. This is useful for displaying lists of people to share with, or for running analytics on your users.

```objc
[CMUser allUsersWithCallback:^(NSArray *users, NSDictionary *errors) {
    NSLog(@"Users: %@", users);
}];
```

Note that only information saved in a user's profile will be returned.
