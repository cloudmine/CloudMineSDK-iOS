CloudMine iOS SDK
=================

This is the native iOS SDK for communicating with the [CloudMine](https://cloudmine.me/) platform. It uses ARC and is compatible with Xcode 4.5 or higher and iOS 6 or higher.

Installation
------------

`pod 'CloudMine', '~> 1.6'`

Add that line to your Podfile.

The CloudMine library now uses [Cocoapods](http://cocoapods.org/) to manage it's dependencies and packaging. This has many benefits for the end user, such as:

* Pod users can see the CloudMine source code, so you know where things are breaking. This makes it easier for you to debug, and easier for you to help us.
* Pod users have the ability to modify the source code if you need to, which allows for you to tweak the code as necessary, and easy to submit a patch once you fixed a bug.
* Cocoapods' share dependencies between Libraries. If two libraries are using AFNetworking, it gets downloaded once and is used for both, there are no collisions.
* Installing pods is as easy as `pod 'CloudMine'`, with a great website to help support them.
* Pushing and installing updates is super fast and easy. CloudMine simply update the main repo with our new version (which points to the CloudMine Repo), and then you simply run "pod update" and you get the new update.


Documentation
-------------

CloudMine has documentation [here](https://cloudmine.me/docs/ios). The library also has documentation in the header files. There is also the [documentation overview](http://cloudmine.me/developer_zone#ios/overview) on our website for more details.

Building the Library
--------------------

1. Install Cococapods: `sudo gem install cocoapods`
1. Download the repository to your local machine: `git clone git://github.com/cloudmine/cloudmine-ios.git;cd cloudmine-ios`
2. Get the dependenices: `pod install`.
3. At this point, the framework can be modified and edited. To do so, open the `cm-ios.xcworkspace` file in XCode. Do not open any of the project files in the `ios/` directory directly, as things won't work properly.
4. If you want to use your local version of the library in your application, you can use: `pod 'CloudMine', :path => '~/path/to/iOS-SDK/'` to checkout the local version.

## Testing ##
Use the `libcloudmine` scheme for development work and for running the unit tests. To run the tests, select the libcloudmine scheme and do **Product -> Test** (⌘U). All the unit tests are written using [Kiwi](https://github.com/allending/Kiwi/wiki), a nice BDD-style unit testing framework.


Contributing
------------

Contributions to the SDK are always welcome. However, please be sure you have well-written tests that cover all your cases. Since this is a framework, it is sometimes hard to test what you've written using unit tests. If that is the case for your contribution, write a small sample iPhone or iPad application (it doesn't even need a UI) that demonstrates the correct, intended functionality of your additions to the framework. Once all that is done, submit a pull request clearly explaining your additions and providing links to the external test cases if applicable. If you have any questions, please contact the maintainer directly at marc@cloudmine.me or ethan@cloudmine.me.

Thanks in advance for all your hard work and awesome code! :)

