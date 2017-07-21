# Getting the iOS Library

CloudMine has an iOS Library that makes integrating with CloudMine’s services a breeze.

## Requirements
* iOS 8.0 or greater
* Xcode 5 or greater

The library *is* Swift compatible.

## Installing (Current Version: {[{version}]})
Currently the only supported installation method is [CocoaPods](http://cocoapods.org/). CocoaPods is a powerful package manager for iOS apps and allows for you to easily add third party libraries. It also manages dependencies between libraries for you.

To install, add this to your Podfile:

```ruby
pod 'CloudMine', '{[{version}]}'
```

If you're developing your app in Swift, you should also add the `use_frameworks!` directive to the top of your Podfile. This option also works for Objective-C projects targeting iOS 8 or later.

```ruby
use_frameworks!

pod 'CloudMine', '{[{version}]}'
```

If you are developing your app in Swift but are unable to use frameworks, you'll have to use an [Objective-C Bridging header](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) to import the SDK.

You can also point the Podfile to the CloudMine public repo and get the latest version straight from Github:

```ruby
pod 'CloudMine', :git => 'git@github.com:cloudmine/CloudMineSDK-iOS.git'
```

Check out the [iOS Library API reference](http://cocoadocs.org/docsets/CloudMine/)

### GitHub

We're actively developing and invite you to fork and send pull requests on GitHub.

[CloudMineSDK-iOS on GitHub](https://github.com/cloudmine/CloudMineSDK-iOS)

Before you can begin using the iOS Library, you must first [create an application](https://compass.cloudmine.io/dashboard/#/app/create) in the CloudMine dashboard.

## Sample Apps
The following applications are examples that demonstrate how to properly use CloudMine's iOS Library.

* [Todoly](https://github.com/cloudmine/cloudmine-ios-sample-todo) - A simple application that demonstrates CloudMine's user authentication and object storage APIs. It displays a simple, per-user todo list.
