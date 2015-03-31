# Fetch User File

Unlike objects, files can only be loaded one at a time.

```objc
[store userFileWithName:@"kitten.jpg" additionalOptions:nil callback:^(CMFileFetchResponse *response) {
    NSData *imageData = response.file.fileData;
 
    // do something with the data..
}];
```
