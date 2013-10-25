Pod::Spec.new do |s|
  s.name         = "CloudMine"
  s.version      = "1.5.9"
  s.summary      = "The iOS Framework for interacting with the CloudMine platform."
  s.description  = <<-DESC
                   CloudMine is a powerful backend as a service that allows you to easily store your apps data in the cloud.
                   DESC
  s.homepage     = "https://cloudmine.me/docs/ios/reference"
  s.license      = 'MIT'
  s.author       = { "CloudMine" => "support@cloudmine.me" }
  s.platform     = :ios, '5.0'
  s.source       = { :git => "https://github.com/Wayfarer247/CloudMine-iOS-Testbed.git", :tag => "v1.5.9" }
  s.source_files  = 'ios/ios/src/**/*.{h,m}'
  s.exclude_files = 'math+floats.h', 'NSString+UUID.h', 'NSURL+QueryParameterAdditions.h', 'CMObject+Private.h', 'CMObjectClassNameRegistry.h'
  s.frameworks = 'UIKit', 'CoreGraphics', 'MobileCoreServices', 'SystemConfiguration', 'CFNetwork', 'Foundation', 'CoreFoundation', 'CoreLocation'
  s.libraries = 'z'
  s.requires_arc = true
  s.xcconfig = { 'OTHER_LDFLAGS' => '-all_load, -ObjC', 'FRAMEWORK_SEARCH_PATHS' => '"$(SRCROOT)/ios/Vendor"/**' }

  s.dependency 'AFNetworking', '~> 1.3.3'
  s.dependency 'MAObjCRuntime', '~> 0.0.1'
  s.dependency 'SPSuccinct', '~> 1.0.1'
end
