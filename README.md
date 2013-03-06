CloudMine iOS SDK
=================

This is the native iOS SDK for communicating with the [CloudMine](https://cloudmine.me/) platform. It uses ARC (Automatic Reference Counting) and is thus **compatible only with XCode 4.1 or higher and iOS 4 or higher.**

Installation
------------

CloudMine hosts the most recent version of the Library in a packaged format already. You can download it [here](https://cloudmine.me/docs/ios).

1. Download the library from CloudMine.
2. Extract the CloudMine.framework and drag it into your Xcode project. Ensure "**Copy items into destination group's folder**" is checked, and to check your **application's target** in the "Targets" section.
3. The iOS Library has some dependencies which needed to be added to your App:  
  3.1 CFNetwork.framework  
  3.2 CoreGraphics.framework  
  3.3 libz.dylib  
  3.4 MobileCoreServices.framework  
  3.5 SystemConfiguration.framework  
  3.6 UIKit.framework  
4. The iOS Library also requires some linker flags to be set in the project, due to its nature as a static library. From the **project editor**, select your **application's target**, go into the **Build Settings** tab, and add the `-all_load` and `-ObjC` flags to the **Other Linker Flags** section.


Watch the introductory [screencast](http://cloudmine.me/developer_zone#ios/tutorials) to see how to set up a new iOS project in XCode using the CloudMine framework, including how to specify all the dependencies.

Please see the [documentation overview](http://cloudmine.me/developer_zone#ios/overview) on our website for more details.

Building the Library
--------------------

1. Download the repository to your local machine: `git clone git://github.com/cloudmine/cloudmine-ios.git;cd cloudmine-ios`
2. Get the submodules for the repository: `git submodule update --init`
3. At this point, the framework can be modified and edited. To do so, open the `cm-ios.xcworkspace` file in XCode. Do not open any of the project files in the `ios/` directory directly, as things won't work properly.
4. To build the framework, choose the `CloudMine Universal Framework` scheme, clean, and build. This will build a universal framework that can run both on the iOS simulator as well as an iOS device. You can find the resulting framework under `ios/build/Release-iphoneuniversal`.

## Testing ##
Use the `libcloudmine` scheme for development work and for running the unit tests. To run the tests, select the libcloudmine scheme and do **Product -> Test** (⌘U). All the unit tests are written using [Kiwi](https://github.com/allending/Kiwi/wiki), a nice BDD-style unit testing framework.


Contributing
------------

Contributions to the SDK are always welcome. However, please be sure you have well-written tests that cover all your cases. Since this is a framework, it is sometimes hard to test what you've written using unit tests. If that is the case for your contribution, write a small sample iPhone or iPad application (it doesn't even need a UI) that demonstrates the correct, intended functionality of your additions to the framework. Once all that is done, submit a pull request clearly explaining your additions and providing links to the external test cases if applicable. If you have any questions, please contact the maintainer directly at marc@cloudmine.me.

Thanks in advance for all your hard work and awesome code! :)

