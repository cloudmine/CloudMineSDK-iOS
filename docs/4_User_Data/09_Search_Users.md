#Search for Users in Application

User profiles can be queried using the [query language](#/rest_api#overview) over profiles.

This will find all users where the user's name is "Derek". This matches the example user saved in the [Update User Profile](#/ios#update-user-profiles) example above.

```objc
[CMUser searchUsers:@"[name = \"Derek\"]" callback:^(CMObjectFetchResponse *response) {
    NSLog(@"Users: %@", response.objects);
}];
```
