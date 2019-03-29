Pod::Spec.new do |s|
  s.name             = "UIKitBase"
  s.summary          = "A short description of UIKitBase."
  s.version          = "0.0.22"
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
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/Core/**/*'
    core.exclude_files = 'Sources/**/**/*.{svg, .py}'
    core.resource_bundle = {
        'UIKitBase' => ['Sources/Core/Assets/**/*.{ttf,bundle,xib,nib}']
    }
    core.dependency 'Swiftest'
    core.dependency 'UIKitTheme'
    core.dependency 'UIKitMixinable'
    core.dependency 'UIKitExtensions'
    core.dependency 'Layman'
    core.dependency 'DarkMagic'
    core.dependency 'UIFontIcons'
    core.dependency 'Actions'
    core.dependency 'Nuke'

    #core.dependency 'DeepDiff'
    core.dependency 'Algorithm'

    core.ios.dependency 'AssistantKit'
    core.frameworks = 'UIKit'
  end

  s.subspec 'Authentication' do |a|
   a.source_files = 'Sources/Subspecs/Authentication/Source/**/*'
   a.dependency 'UIKitBase/Forms'
  end

  s.subspec 'Datasource' do |d|
    d.source_files = 'Sources/Subspecs/Datasource/**/*'
    d.dependency 'UIKitBase/Core'
  end

  s.subspec 'Forms' do |f|
   f.source_files = 'Sources/Subspecs/Forms/Source/**/*'
   f.dependency 'UIKitBase/Core'
   f.dependency 'ActiveLabel'
     f.subspec 'Location' do |fl|
       fl.source_files = 'Sources/Subspecs/Forms/Subspecs/Location/**/*'
       fl.dependency 'UIKitBase/Location'
        end
     f.subspec 'Date' do |d|
       d.source_files = 'Sources/Subspecs/Forms/Subspecs/Date/**/*'
       d.dependency 'SwiftDate'
     end
     f.subspec 'LegalDisclosure' do |l|
       l.source_files = 'Sources/Subspecs/Forms/Subspecs/LegalDisclosure/**/*'
       l.dependency 'ActiveLabel'
     end
  end

  s.subspec 'Location' do |l|
   l.source_files = 'Sources/Subspecs/Location/Source/**/*'
   l.dependency 'UIKitBase/Permission'
   l.dependency 'Permission/Location'
   l.dependency 'SwiftLocation'
  end

  s.subspec 'Permission' do |p|
   p.source_files = 'Pod/Subspecs/Permission/Source/**/*'
   p.dependency 'UIKitBase/Core'
   p.dependency 'Permission'
  end

end
