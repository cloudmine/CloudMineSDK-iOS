# Tutorial

This tutorial will walk you through building a car management app. It will let you organize your cars, search through them and get details about each one.

If you haven't read through the iOS [getting started](#/ios#getting-the-ios-library) section, we recommend you read that first, and come back to the tutorial after you've set up your environment.

## Initialize the Library

Before you can use the iOS Library in your application, you must first provide it your CloudMine credentials. If you do not have any CloudMine credentials, you [should get them from the application dashboard](/dashboard).

The first step in initializing the iOS Library is to add the following import at the top of your application delegate’s `.m` file:

```objc
#import <CloudMine/CloudMine.h>
```

Next, put the following code into your application delegate’s `application:didFinishLaunchingWithOptions:` method. This ensures that it will run right after your application is launched. Make sure to replace the `appIdentifier` and `appSecret` values with the values you got from the CloudMine dashboard.

```objc
CMAPICredentials *credentials = [CMAPICredentials sharedInstance];
credentials.appIdentifier = @"84e5c4a381e7424b8df62e055f0b69db";
credentials.appSecret = @"84c8c3f1223b4710b180d181cd6fb1df";
```

Once this is set up, we can begin creating objects that will be saved to CloudMine.

## Create the Car Object

Before we can persist data to CloudMine, we need an object to store. For this application, we're going to create a class that represents a car.

In Xcode, create a new class named `CMCar`:

* From Xcode’s **File** menu, select **New → File...***, or use the keyboard shortcut **⌘N**.
* Under the **Cocoa Touch** section, select the file type of **Objective-C class** and click **Next**.
* Name the class `CMCar` , and make sure that it is a subclass of `CMObject`, and not `NSObject`.

Now, you need to define properties on `CMCar`, so that it can store the information you are looking to store. For this example we are going to have properties for the make, model, and year of the car. Add the following to `CMCar.h`:

```objc
#import <CloudMine/CloudMine.h>
 
@interface CMCar : CMObject
 
@property (strong, nonatomic) NSString *make;
@property (strong, nonatomic) NSString *model;
@property (nonatomic) NSInteger year;
 
@end
```

Now that the interface of the class has been defined, the next step is to implement it, and specifically, implement the `NSCoding` protocol.

Our main goal is to enable CMCar instances to properly encode and decode themselves, storing the values of their properties in an encoder. This uses the NSCoding protocol. Put the following in the implementation of `CMCar` in `CMCar.m`:

```objc
#import "CMCar.h"
 
@implementation CMCar
 
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_make forKey:@"make"];
    [aCoder encodeObject:_model forKey:@"model"];
    [aCoder encodeInteger:_year forKey:@"year"];
}
 
- (id)initWithCoder:(NSCoder *)aCoder {
    if ((self = [super initWithCoder:aCoder])) {
        _make = [aCoder decodeObjectForKey:@"make"];
        _model = [aCoder decodeObjectForKey:@"model"];
        _year = [aCoder decodeIntegerForKey:@"year"];
    }
    return self;
}
 
@end
```

## Store Cars

Once we've defined a class, we can persist it to the CloudMine platform. We're going to create a few cars in our didFinishLaunchingWithOptions: method of our main AppDelegate class, and save them to CloudMine.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
 
    // initialization the library
    CMAPICredentials *credentials = [CMAPICredentials sharedInstance];
    credentials.appIdentifier = @"84e5c4a381e7424b8df62e055f0b69db";
    credentials.appSecret = @"84c8c3f1223b4710b180d181cd6fb1df";
 
    // Create a car instance
    CMCar *porsche = [[CMCar alloc] init];
    porsche.make = @"Porsche";
    porsche.model = @"Roadster";
    porsche.year = 2012;
 
    [porsche save:^(CMObjectUploadResponse *response) {
        NSLog(@"Status: %@", [response.uploadStatuses objectForKey:porsche.objectId]);
    }];
 
    // Create another 
    CMCar *honda = [[CMCar alloc] init];
    honda.make = @"Honda";
    honda.model = @"Civic";
    honda.year = 2012;
 
    [honda save:^(CMObjectUploadResponse *response) {
        NSLog(@"Status: %@", [response.uploadStatuses objectForKey:honda.objectId]);
    }];
 
    return YES;
}
```

Start the application in the simulator. You should see some output indicating that the objects were created.

Now if you look at your [dashboard](/dashboard), you'll see the two cars that were saved.

{{note "A unique ID will be generated for each of the saved objects every time the code runs. So if you run the above code multiple times, you'll end up with several hondas and toyotas."}}

## Search for Cars

Now that we've created and saved a few cars, let's see how to get them back from the cloud. To make things interesting, we will only request Hondas to be returned using the search query `[make = "honda"]`.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ...initialization code...
    // ...car creation and saving code...
 
    CMStore *store = [CMStore defaultStore];
 
    [store searchObjects:@"[make = \"Honda\"]"
       additionalOptions:nil
                callback:^(CMObjectFetchResponse *response) {
                    NSLog(@"Hondas: %@", response.objects);
                }
    ];
}
```

And that's it. You are now saving and retrieving data from the cloud in a few lines of code!

{{note "The library uses callbacks so that responses are handled correctly and do not block the calling (and most frequently, the UI) thread. Callbacks are run in the original thread that the request was called from while all the networking operations and blocking occurs on a background thread."}}

## Putting it all together

Here's all the code in one complete example.

#### CMCar.h
```objc
#include <CloudMine/CloudMine.h>
 
@interface CMCar : CMObject
 
@property (strong, nonatomic) NSString *make;
@property (strong, nonatomic) NSString *model;
@property (nonatomic) NSInteger year;
 
@end
```

#### CMCar.m
```objc
#import "CMCar.h"
 
@implementation CMCar
 
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_make forKey:@"make"];
    [aCoder encodeObject:_model forKey:@"model"];
    [aCoder encodeInteger:_year forKey:@"year"];
}
 
- (id)initWithCoder:(NSCoder *)aCoder {
    if ((self = [super initWithCoder:aCoder])) {
        _make = [aCoder decodeObjectForKey:@"make"];
        _model = [aCoder decodeObjectForKey:@"model"];
        _year = [aCoder decodeIntegerForKey:@"year"];
    }
 
    return self;
}
 
@end
```

#### AppDelegate.m

````objc
#import "CMCar.h"
 
@implementation CMAppDelegate
 
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
 
    CMAPICredentials *credentials = [CMAPICredentials sharedInstance];
    credentials.appIdentifier = @"2064c7d07e2f424da6e6ba57333f7820";
    credentials.appSecret = @"a06e41ed627748029bedacd2571e3713";
 
    // Create a car instance
    CMCar *porsche = [[CMCar alloc] init];
    porsche.make = @"Porsche";
    porsche.model = @"Roadster";
    porsche.year = 2012;
 
    [porsche save:^(CMObjectUploadResponse *response) {
        NSLog(@"Status: %@", [response.uploadStatuses objectForKey:porsche.objectId]);
    }];
 
    // Create another
    CMCar *honda = [[CMCar alloc] init];
    honda.make = @"Honda";
    honda.model = @"Civic";
    honda.year = 2012;
 
    [honda save:^(CMObjectUploadResponse *response) {
        NSLog(@"Status: %@", [response.uploadStatuses objectForKey:honda.objectId]);
    }];
 
    CMStore *store = [CMStore defaultStore];
 
    [store searchObjects:@"[make = \"Honda\"]"
       additionalOptions:nil
                callback:^(CMObjectFetchResponse *response) {
                    NSLog(@"Hondas: %@", response.objects);
                }];
 
    return YES;
}
 
// ...XCode generated code...
 
@end
```

## Next Steps

Now that you've seen the basics, start coding up your app! The [iOS SDK Reference](#/ios#application-data) has plenty of examples to help you accomplish what you need to using CloudMine.

You can also check out our sample application that makes extensive use of the various CloudMine features [right here](https://github.com/cloudmine/CloudMine-CloudClicker-iOS).

Also, don't forget that if you can't find what you're looking for in these docs, you are always welcome to [email CloudMine support](mailto:support@cloudmineinc.com).

Happy coding!
