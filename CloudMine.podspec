Pod::Spec.new do |s|
  s.name         = "CloudMine"
  s.version      = "1.7.9"
  s.summary      = "The iOS Framework for interacting with the CloudMine platform."
  s.homepage     = "https://cloudmine.me/docs/#/ios"
  s.license      = 'MIT'
  s.author       = { "CloudMine" => "support@cloudmine.me" }
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/cloudmine/cloudmine-ios.git", :tag => "v#{s.version}" }
  s.source_files  = 'ios/ios/src/**/*.{h,m}'
  s.exclude_files = 'NSString+UUID.h', 'NSURL+QueryParameterAdditions.h', 'CMObject+Private.h', 'CMObjectClassNameRegistry.h', 'MARTNSObject.{h,m}', 'RT*.{h,m}'
  s.frameworks = 'UIKit', 'CoreGraphics', 'MobileCoreServices', 'SystemConfiguration', 'CFNetwork', 'Foundation', 'CoreFoundation', 'CoreLocation', 'Social', 'Accounts'
  s.libraries = 'z'
  s.requires_arc = true
  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = 'ios/ios/src/**/MARTNSObject*.{h,m}', 'ios/ios/src/**/RT*.{h,m}'
  end

  s.dependency 'AFNetworking', '~> 2.6.3'

  s.prefix_header_contents = '#import <SystemConfiguration/SystemConfiguration.h>', '#import <MobileCoreServices/MobileCoreServices.h>'
end
