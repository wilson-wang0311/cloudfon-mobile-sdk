Pod::Spec.new do |s|
  s.name             = 'CloudFonMobileSDK'
  s.version          = '1.0.1'
  s.summary          = 'CloudFon Mobile SDK for iOS'
  s.description      = 'CloudFon Mobile SDK for iOS - WebView based chat solution'
  s.homepage         = 'https://github.com/wilson-wang0311/cloudfon-mobile-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CloudFon Team' => 'dev@cloudfon.com' }
  s.source           = { :git => 'https://github.com/wilson-wang0311/cloudfon-mobile-sdk.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  
  s.source_files = 'Sources/**/*.swift'
  
  s.frameworks = 'UIKit', 'WebKit'
  
  s.dependency 'SnapKit', '~> 5.6'
end