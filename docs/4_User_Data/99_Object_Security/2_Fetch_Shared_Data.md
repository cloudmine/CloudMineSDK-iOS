# Fetching Shared User Data

Once you've [granted access to an object](#/ios#create-access-list) with an access list, other users with permission can fetch the shared object.

If you are requesting the shared object with its ID explicitly, the object will be automatically fetched.

```objc
[store objectsWithKeys:[NSArray arrayWithObjects:@"object1", nil]
              callback:^(CMObjectFetchResponse *response) {
                  NSLog(@"loaded: %@", response.objects);
}];
```

However, if you want to load it through a search or by loading all of the user objects, it will not be returned UNLESS you include CMStoreOptions in your request, with [CMStoreOptions.shared](http://cocoadocs.org/docsets/CloudMine/1.7.0/Classes/CMStoreOptions.html#//api/name/shared) set to true.

```objc
CMStoreOptions *options = [[CMStoreOptions alloc] initWithPagingDescriptor:nil];
options.shared = YES;
 
[store searchObjects:@"[make = \"Porsche\"]"
   additionalOptions:options
            callback:^(CMObjectFetchResponse *response) {
                NSLog(@"Objects: %@", response.objects);
            }];
```
			
