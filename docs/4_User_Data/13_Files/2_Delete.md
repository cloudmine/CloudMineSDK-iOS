# Delete User File

Delete files by sending the deleteUserFileNamed message to CMStore.

```objc
[store deleteUserFileNamed:@"kitten.jpg" additionalOptions:nil callback:^(CMDeleteResponse *response) {
    // check response status
    NSString *status = [response.success objectWithKey:@"kitten.jpg"];
    // status == "deleted"
}];
```
