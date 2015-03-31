# CUSTOM SERVER CODE

Custom code execution allows you to write custom JavaScript code snippets that run on our servers to perform processing and post-processing operations that are inappropriate to run on a mobile device or to offload certain business logic to the server. Your code runs in a sandboxed server-side JavaScript environment that has access to the CloudMine [JavaScript API](http://github.com/cloudmine/cloudmine-js) and a simple HTTP client. All snippets are killed after 30 seconds of execution.

Server-side snippets are invoked in Java by creating an instance of CMServerFunction This indicates the name of the snippet and parameters to pass to it. Include this object in the CMStoreOptions for the request.

```objc
// initialize CMStoreOptions
CMStoreOptions *options = [[CMStoreOptions alloc] 
                            initWithPagingDescriptor:[[CMPagingDescriptor alloc] 
                                       initWithLimit:1]];
// add the server side function to the options
options.serverSideFunction = [CMServerFunction serverFunctionWithName:@"mySnippet"];
 
// when this request is made, the function will be invoked
CMStore *store = [CMStore defaultStore];
[store allObjectsWithOptions:options
                    callback:^(CMObjectFetchResponse *response) {
                         NSLog(@"Objects: %@", response.objects);
                    }
];
```

This will call the function named `mySnippet` before returning the requested objects.

If you only want to run a code snippet, you can use a method on CMWebService. This will run a snippet and return the result without going throguh the store or fetching objects.

```objc
[[[CMStore defaultStore] webService] runSnippet:@"test_snippet"
                                     withParams:@{@"firstParam" : @"firstArg"}
                                           user:[[CMStore defaultStore] user]
                                 successHandler:^(id snippetResult, NSDictionary *headers) {
                                     // Success!
                                     NSLog(@"Result: %@", snippetResult);
                                } errorHandler:^(NSError *error) {
                                     // Error!
                                }];
```

## Code Snippet Options

CMServerFunction has several options to control code snippet execution.

### CMServerFunction options

* boolean resultOnly 
  * Only include the results of the snippet call in the response.

* boolean async 
  * Don't wait for the snippet execution to complete before returning.

* NSDictionary *extraParameters 
  * These will be passed into the snippet as parameters.
