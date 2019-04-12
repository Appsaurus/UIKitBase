Pod::Spec.new do |s|
  s.name             = "UIKitBase"
  s.summary          = "A short description of UIKitBase."
  s.version          = "0.0.28"
  s.homepage         = "github.com/Strobocop/UIKitBase"
  s.license          = 'MIT'
  s.author           = { "Brian Strobach" => "brian@appsaurus.io" }
  s.source           = {
    :git => "https://github.com/appsaurus/UIKitBase.git",
    :tag => s.version.to_s
  }

  s.swift_version = '5.0'
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
   a.resource_bundle = {
       'Authentication' => ['Sources/Subspecs/Authentication/Resources/**/*']
   }
  end

  s.subspec 'Datasource' do |d|
    d.source_files = 'Sources/Subspecs/Datasource/**/*'
    d.dependency 'DifferenceKit'
    d.dependency 'UIKitBase/Core'
  end

  s.subspec 'Forms' do |f|
    f.source_files = 'Sources/Subspecs/Forms/Core/**/*'
    f.dependency 'UIKitBase/Core'
    f.dependency 'ActiveLabel'
    f.subspec 'Authentication' do |fl|
        fl.source_files = 'Sources/Subspecs/Forms/Subspecs/Authentication/**/*'
        fl.dependency 'CountryPickerSwift'
        fl.dependency 'PhoneNumberKit'
    end
    f.subspec 'Date' do |d|
      d.source_files = 'Sources/Subspecs/Forms/Subspecs/Date/**/*'
      d.dependency 'SwiftDate'
    end
    f.subspec 'LegalDisclosure' do |l|
      l.source_files = 'Sources/Subspecs/Forms/Subspecs/LegalDisclosure/**/*'
      l.dependency 'ActiveLabel'
    end
    f.subspec 'Location' do |fl|
        fl.source_files = 'Sources/Subspecs/Forms/Subspecs/Location/**/*'
        fl.dependency 'UIKitBase/Location'
    end
  end

  s.subspec 'Location' do |l|
   l.source_files = 'Sources/Subspecs/Location/**/*'
   l.dependency 'UIKitBase/Permission'
   l.dependency 'UIKitBase/Datasource'
   l.dependency 'Permission/Location'
   l.dependency 'SwiftLocation'
  end

  s.subspec 'Permission' do |p|
   p.source_files = 'Sources/Subspecs/Permission/**/*'
   p.dependency 'UIKitBase/Core'
   p.dependency 'Permission'
  end

end
