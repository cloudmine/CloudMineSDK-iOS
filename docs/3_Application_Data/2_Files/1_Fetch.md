# Fetch File

Unlike objects, files can only be loaded one at a time.

```objc
[store fileWithName:@"kitten.jpg" additionalOptions:nil callback:^(CMFileFetchResponse *response) {
    NSData *imageData = response.file.fileData;
 
    // do something with the data..
}];
```	
