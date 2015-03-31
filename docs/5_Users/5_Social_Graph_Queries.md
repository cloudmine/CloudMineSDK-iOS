# Social Graph Queries

{{note 'You will need to configure each social network you plan on using in your app using each network\'s website.'}}

In addition to logging in through social networks, queries can also be run on the networks through the API. Any query you can run on a social network directly can be made through the CloudMine API. This allows for a single point of access for networking calls, as well as letting the CloudMine SDK handle the creation, delivery, and response of the call. These calls are made through the CMWebService class, and require a user to be logged in (through any social network you want to send queries to).

Let's say we have a user logged in through Twitter, and we want to get the home timeline of the user. The [Twitter Docs](https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline) for the timeline explain the call that needs to be made.

```objc
CMStore *store = [CMStore defaultStore];
 
[store.webService runSocialGraphQueryOnNetwork:CMSocialNetworkTwitter
                                       withVerb:@"GET"
                                      baseQuery:@"statuses/home_timeline.json"
                                     parameters:@{@"include_entities":@YES}
                                        headers:nil
                                    messageData:nil
                                       withUser:aCMUserLoggedInToTwitter
                                 successHandler:^(NSString *results, NSDictionary *headers) {
                                    NSLog(@"Success!");
                                 } errorHandler:^(NSError *error) {
                                    NSLog(@"Error: %@", error);
                                 }];
```

Any extra parameters you want included in the query should be passed in through the parameters, these will be encoded as JSON and passed through to the service you're targeting. In the successHandler, the result of the query will be returned directly as a string, as the framework cannot make any assumptions of the type of data returning.

Because GET requests should not modify data, there is a convenience method for sending GET requests that makes forming them a little easier.

```objc
CMStore *store = [CMStore defaultStore];
 
[store.webService runSocialGraphGETQueryOnNetwork:CMSocialNetworkTwitter
                                        baseQuery:@"statuses/home_timeline.json"
                                       parameters:@{@"include_entities":@YES}
                                          headers:nil
                                         withUser:gUser
                                   successHandler:^(NSString *results, NSDictionary *headers) {
                                       NSLog(@"Success! %@", results);
                                   } errorHandler:^(NSError *error) {
                                       NSLog(@"Error: %@", error);
                                   }];
```

POST requests are also easy to make. When making requests it is a good idea to always set the "Content-Type" header fields. Some API's may work without any set, but it is better to be safe. CloudMine makes no assumption as to what type of data you are sending. For example, posting a gist to Github:

```objc
CMStore *store = [CMStore defaultStore];      
 
NSString *data = @"{\"description\":\"Testing Gist!\",\"public\":true,\"files\":{\"FileNameHere.txt\":{\"content\":\"Gist file contents, you can just write your gist here!\"}}}";
 
[store.webService runSocialGraphQueryOnNetwork:CMSocialNetworkGithub
                                      withVerb:@"POST"
                                     baseQuery:@"gists"
                                    parameters:nil
                                       headers:@{@"Content-Type" : @"application/json"}
                                   messageData:[data dataUsingEncoding:NSUTF8StringEncoding]
                                      withUser:aCMuserLoggedInToGithub
                                successHandler:^(NSString *results, NSDictionary *headers) {
                                    NSDictionary *parsed = [results yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:nil];
                                    if (parsed) {
                                      NSLog(@"Parsed Dictionary: %@", parsed);
                                    }                                        
                                } errorHandler:^(NSError *error) {
                                    NSLog(@"Error: %@", error);
                                }];
```

{{note 'Certain services require additional permissions in order to do certain actions. Github and LinkedIn are two such services; Github requires the "gist" scope in order to posts gists as a user. These must be asked for when the user logs in.'}}

{{note "Headers are a tricky business. CloudMine tries hard to pass back appropriate headers from the target service, but not all are passed back. Information about the request (content-type, content-length) should always be passed back, but information about the target services (server, cache-control, x-powered-by) will reflect CloudMine, not the target service."}}

In the gist request, the data is just a string formatted into JSON, and is added to the POST request. The data for these request can be anything, so the NSString needs to be converted into an NSData object.
