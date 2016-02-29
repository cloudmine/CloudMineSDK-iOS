# Delete User Objects

Any object can be deleted by sending the deleteObject message to the store, along with the object you would like to delete.

```objc
[store deleteUserObject:car
      additionalOptions:nil
               callback:^(CMDeleteResponse *response) {
                   NSLog(@"Status: %@ %@", [response.success objectForKey:car.objectId]);
}];
```

The object will be deleted from the server, as well as removed from the local CMStore.
