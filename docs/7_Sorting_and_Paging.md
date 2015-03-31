# Sorting and Paging

## Sorting

{{warning "There is a bug in the current iOS library. This bug causes objects to be returned unsorted, even if a `CMSortDescriptor` was passed in the method call. Paging will still work as normal, but the objects will have to be **resorted client side.**"}}

By default, loaded objects are returned in an undefined (and often inconsistent) order. You can specify fields to sort by using CMSortDescriptor, along with the direction of the sort.

```objc
CMSortDescriptor *sortDescriptor = [[CMSortDescriptor alloc] 
                                     initWithFieldsAndDirections:@"text", CMSortDescending, nil]]
 
[store allObjectsWithOptions:[[CMStoreOptions alloc] initWithSortDescriptor:sortDescriptor
                    callback:^(CMObjectFetchResponse *response) {
                        NSLog(@"loaded: %@", response.objects);
}];
```

The objects in the response will be ordered by the field "text", descending.

## Paging

Paging is used to control the number of results returned from each request. Use the CMPagingDescriptor class to set paging parameters.

```objc
CMPagingDescriptor *pagingDescriptor = [[CMPagingDescriptor alloc] initWithLimit:2 skip:1 includeCount:YES]]
 
[store allObjectsWithOptions:[[CMStoreOptions alloc] initWithPagingDescriptor:pagingDescriptor
                    callback:^(CMObjectFetchResponse *response) {
                      NSLog(@"loaded: %@", response.objects);
                      NSLog(@"count: %i", response.count);
}];
```

## CMPagingOptions properties

* NSInteger limit 
  * The maximum number of objects to return.
* NSUInteger skip 
  * Number of objects to skip before returning.
* BOOL includeCount 
  * true if the response should include the total number of results for the query, regardless of the value for limit or skip.
