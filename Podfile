#
# Podfile for CloudMine SDK on iOS
#
source 'https://github.com/CocoaPods/Specs.git'
#
# Supporting iOS 8 and above
#
platform :ios, '8.0'

#
# Define the workspace we had before Cocoapods
#
workspace 'cm-ios'

#
# Define the XCode project file we already had before Cocoapods
#
project 'ios/cloudmine-ios.xcodeproj/'

#
# Inhibit all Warnings in Pods. We are trusting the pods we use to
# stay up to date and not have warnings which cause issues. When building
# the CloudMine Library, we want 0 warnings, and so any noise should be
# ignored.
#
inhibit_all_warnings!

target 'cloudmine-ios' do
  #
  # The Pods for CloudMine SDK usage. AFNetworking for networking
  #
  pod 'AFNetworking', '2.6.3'

  #
  # The Pods for testing the iOS SDK. Kiwi is our BDD testing framework
  # and NSData+Base64 is used in examining base64 data in requests.
  #
  target 'cloudmine-iosTests' do
    inherit! :search_paths
    pod 'Kiwi', '2.4.0'
    pod 'NSData+Base64', '1.0.0'
  end
end
