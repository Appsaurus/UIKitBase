Pod::Spec.new do |s|
  s.name             = "UIKitBase"
  s.summary          = "A short description of UIKitBase."
  s.version          = "0.0.1"
  s.homepage         = "github.com/Strobocop/UIKitBase"
  s.license          = 'MIT'
  s.author           = { "Brian Strobach" => "brian@appsaurus.io" }
  s.source           = {
    :git => "https://github.com/appsaurus/UIKitBase.git",
    :tag => s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/Strobocop'

  s.swift_version = '4.2'
  s.requires_arc = true

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.2'
  s.watchos.deployment_target = "3.0"

  s.ios.source_files = 'Sources/{iOS,Shared}/**/*'
  s.tvos.source_files = 'Sources/{iOS,tvOS,Shared}/**/*'
  s.osx.source_files = 'Sources/{macOS,Shared}/**/*'
  s.watchos.source_files = 'Sources/{watchOS,Shared}/**/*'

  # s.ios.frameworks = 'UIKit', 'Foundation'
  # s.osx.frameworks = 'Cocoa', 'Foundation'

end
