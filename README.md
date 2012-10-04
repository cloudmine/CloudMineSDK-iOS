This is the native iOS SDK for CloudMine. It uses ARC (Automatic Reference Counting) and is thus **compatible only with XCode 4.1 or higher and iOS 4 or higher.**

It has the following dependencies:

* CFNetwork
* SystemConfiguration
* MobileCoreServices
* CoreGraphics
* UIKit
* libz

You must also set the `-all_load` and `-ObjC` flags in the **Other Linker Flags** section of your app's build settings.

Watch the introductory [screencast](http://cloudmine.me/developer_zone#ios/tutorials) to see how to set up a new iOS project in XCode using the CloudMine framework, including how to specify all the dependencies.

Please see the [documentation overview](http://cloudmine.me/developer_zone#ios/overview) on our website for more details.

If you wish to simply download the precompiled universal framework, you [may do so](https://github.com/cloudmine/cloudmine-ios/downloads).

Building
-----

The first step is checking out the git submodules for our library dependencies. From the root directory, run `git submodule update --init`.

To modify and build this framework yourself, simply open `cm-ios.xcworkspace` in XCode. Do not open any of the project files in the `ios/` directory directly as things won't work correctly.

There are a few schemes to pick from. Use `libcloudmine` for development work and for running the unit tests. All the unit tests are written using [Kiwi](https://github.com/allending/Kiwi/wiki), a nice BDD-style unit testing framework. When you are ready to build the final framework for use in your own apps, choose the `CloudMine Universal Framework` scheme, clean, and build. This will build a universal framework that can run both on the iOS simulator as well as an iOS device. You can find the resulting framework under `ios/build/Release-iphoneuniversal`.

Contributing
-----

Contributions to the SDK are always welcome. However, please be sure you have well-written tests that cover all your cases. Since this is a framework, it is sometimes hard to test what you've written using unit tests. If that is the case for your contribution, write a small sample iPhone or iPad application (it doesn't even need a UI) that demonstrates the correct, intended functionality of your additions to the framework. Once all that is done, submit a pull request clearly explaining your additions and providing links to the external test cases if applicable. If you have any questions, please contact the maintainer directly at marc@cloudmine.me.

Thanks in advance for all your hard work and awesome code! :)
