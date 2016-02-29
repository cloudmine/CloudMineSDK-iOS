# Search for Objects

For more fine-grained control over which objects are fetched from the server, use the search functionality in CMStore. All queries should be formatted in our [query syntax](#/rest_api#overview).

```objc
[store searchObjects:@"[make = \"Porsche\"]"
   additionalOptions:nil
            callback:^(CMObjectFetchResponse *response) {
                NSLog(@"Objects: %@", response.objects);
            }
];
```

This example will return all objects with a field, "make", with the value "Porsche".
