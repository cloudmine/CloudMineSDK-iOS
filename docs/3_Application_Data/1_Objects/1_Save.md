# Save Objects

Saving an object from the iOS Library will do one of two things. If the object does not currently exist in CloudMine's data store, it will create the object in the store. If it does exist already, then a save operation will update the properties of the object in the store with the properties of the object uploaded.

```objc
CMCar *car = [[CMCar alloc] init];
car.make = @"Porsche";
car.model = @"Roadster";
car.year = 2012;
 
[car save:^(CMObjectUploadResponse *response) {
    NSLog(@"Status: %@", [response.uploadStatuses objectForKey:car.objectId]);
}];
```

This persists the object on the server, and adds it to the local CMStore.
