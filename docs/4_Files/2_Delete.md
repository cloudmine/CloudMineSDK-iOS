# Delete File

Delete files by sending the deleteFileNamed message to CMStore.

```objc
[store deleteFileNamed:@"kitten.jpg" additionalOptions:nil callback:^(CMDeleteResponse *response) {
    // check response status
    NSString *status = [response.success objectWithKey:@"kitten.jpg"];
    // status == "deleted"
}];
```	
