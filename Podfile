#
#
#
platform :ios, '6.0'
workspace 'cm-ios'
xcodeproj 'ios/cloudmine-ios'
inhibit_all_warnings!

target "cloudmine-ios" do 
  pod 'AFNetworking', '~> 1.3.3'
  pod 'MAObjCRuntime', '~> 0.0'
end


target 'cloudmine-iosTests', :exclusive => true do
  pod 'Kiwi', '~> 2.2'
  pod 'NSData+Base64', '~> 1.0'
end
