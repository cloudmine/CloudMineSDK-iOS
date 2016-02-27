# Getting the iOS Library

CloudMine has an iOS Library that makes integrating with CloudMine’s services a breeze.

## Requirements
* iOS 8.0 or greater
* Xcode 5 or greater

The library *is* Swift compatible.

## Installing (Current Version: {[{version}]})
The current only supported installation method is [Cocoapods](http://cocoapods.org/). Cocoapods is a powerful package manager for iOS apps and allows for you to easily add third party libraries. It also manages dependencies between libraries for you.

To install, add this to your Podfile:

```ruby
pod 'CloudMine', '{[{version}]}'
```

You can also point the Podfile to the CloudMine public repo and get the latest version straight from Github:

```ruby
pod 'CloudMine', :git => 'git@github.com:cloudmine/cloudmine-ios.git'
```

Check out the [iOS Library API reference](http://cocoadocs.org/docsets/CloudMine/)

### Github

We're actively developing and invite you to fork and send pull requests on GitHub.

[cloudmine/cloudmine-ios](https://github.com/cloudmine/cloudmine-ios)

Before you can begin using the iOS Library, you must first [create an application](https://compass.cloudmine.me/dashboard/#/app) in the CloudMine dashboard.

## Sample Apps
The following applications are examples that demonstrate how to properly use CloudMine's iOS Library.

* [Todoly](https://github.com/cloudmine/cloudmine-ios-sample-todo) - A simple application that demonstrates CloudMine's user authentication and object storage APIs. It displays a simple, per-user todo list, and just happens to sync with [this JavaScript sample application](https://cloudmine.io/sample-apps/todo/index.html).
