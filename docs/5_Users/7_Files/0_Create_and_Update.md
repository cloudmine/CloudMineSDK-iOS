# Upload / Replace User File

In addition to object data, you are also able to store files in CloudMine. A CMFile consists of the file contents, a file name, and an optional MIME content type. If no content type is specified, a default of "application/octet-stream" is used.

```objc
// assume we have a file, "kitten.jpg". grab the contents
NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] 
                                   pathForResource:@"kitten"
                                            ofType:@"jpg"]];
 
[store saveUserFileWithData:imageData
                      named:@"kitten.jpg"
          additionalOptions:nil
                   callback:^(CMFileUploadResponse *response) {
                       switch(response.result) {
                       case CMFileCreated:
                           // the file was created, do something with it
                           break;
                       case CMFileUpdated:
                           // the file was updated, do something with it
                           break;
                       case CMFileUploadFailed:
                           // upload failed!
                           break;
                       }
                  }
];
```

If a file with this name already exists on the server, its contents will be replaced with the new data.
