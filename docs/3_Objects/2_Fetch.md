# Fetch Objects

Use the CMStore to fetch objects that exist on the server.

Fetching all objects

If you don't want to fetch specific keys, the simplest way is to use allObjectsWithOptions.

```objc
CMStore *store = [CMStore defaultStore];
 
[store allObjectsWithOptions:nil
                    callback:^(CMObjectFetchResponse *response) {
                         NSLog(@"Objects: %@", response.objects);
                    }
];
```

On load, this passes all the objects to the provided callback.

### Fetching all objects of a type

By passing in a class, you can fetch all objects of that type.

```objc
[store allObjectsOfClass:[CMCar class]
       additionalOptions:nil
                callback:^(CMObjectFetchResponse *response) {
                    NSLog(@"Objects: %@", response.objects);
                }
];
```

### Fetching specific keys

Specific objects can be loaded using an array of keys.

```objc
NSArray *keys = [NSArray arrayWithObject:@"my-key"];
 
[store objectsWithKeys:keys
                    additionalOptions:nil
                    callback:^(CMObjectFetchResponse *response) {
                         NSLog(@"Objects: %@", response.objects);
                    }
];
```
