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

Building the Library
--------------------
If you are interested in doing some development on the library:

1. Install Cococapods: `sudo gem install cocoapods`
1. Download the repository to your local machine: `git clone git://github.com/cloudmine/cloudmine-ios.git;cd cloudmine-ios`
2. Get the dependenices: `pod install`.
3. At this point, the framework can be modified and edited. To do so, open the `cm-ios.xcworkspace` file in XCode.
4. If you want to use your local version of the library in your application, you can use: `pod 'CloudMine', :path => '~/path/to/iOS-SDK/'` in your Podfile to checkout the local version.

Testing
-------
If you have added any functionality to the library, ensure that it is well tested. To run the tests, use the `libcloudmine` scheme. To run the tests, select the libcloudmine scheme and do **Product -> Test** (⌘U). All the unit tests are written using [Kiwi](https://github.com/allending/Kiwi/wiki), a nice BDD-style unit testing framework.

Code Coverage
-------------
With over 425 tests (unit and integration), the library has excellent code coverage, with 92.4% line coverage and 99.5% function coverage. The library uses XcodeCoverage to generate the code coverage docs. However, to make this all easier there is a Makefile to do the magic for you.

Since the Makefile runs on the command line, we use the gem *xcpretty* to make the output more readable. Before using the Makefile, you must install this gem (or remove the command from the Makefile).

To install: `gem install xcpretty`

The Makefile lets you build, clean, test, and generate code coverage:

**build**: Cleans and builds the library  
**clean**: Cleans the library  
**cov**: Cleans, builds, tests, and generates the code coverage HTML document.  
**test**: Cleans, builds, and then tests the library.  

So to get code coverage, run `make cov`

Before any pull requests are accepted, your code must be covered and all tests must pass.

Documentation
-------------
CloudMine has documentation [here](https://cloudmine.me/docs/ios). The library also has documentation in the header files. There is also the [documentation overview](http://cloudmine.me/developer_zone#ios/overview) on our website for more details.


Contributing
------------
Contributions to the SDK are always welcome. However, please be sure you have well-written tests that cover all your cases. Once all that is done, submit a pull request clearly explaining your additions and providing links to the external test cases if applicable. If you have any questions, please contact the maintainer directly at ethan@cloudmine.me.

Thanks in advance for all your hard work and awesome code! :)

