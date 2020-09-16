source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!


def shared
    pod 'Swiftest', :git => 'https://github.com/Appsaurus/Swiftest'
    pod 'SwiftLint'
    pod 'SwiftFormat/CLI'
end

def libaryShared
    pod 'UIKitTheme', :git => 'https://github.com/Appsaurus/UIKitTheme'
    pod 'UIKitMixinable', :git => 'https://github.com/Appsaurus/UIKitMixinable'
    #pod 'UIKitMixinable', :path => '../UIKitMixinable'
    pod 'UIKitExtensions', :git => 'https://github.com/Appsaurus/UIKitExtensions'
    pod 'Layman', :git => 'https://github.com/Appsaurus/Layman'
    pod 'DarkMagic', :git => 'https://github.com/Appsaurus/DarkMagic'
    pod 'RuntimeExtensions', :git => 'https://github.com/Appsaurus/RuntimeExtensions'
    pod 'UIFontIcons/MaterialIcons', :git => 'https://github.com/Appsaurus/UIFontIcons'
    pod 'Actions'
    pod 'Nuke'
    pod 'ActiveLabel'
    pod 'SwiftLint'
    pod 'Algorithm'
    pod 'SwiftLocation'
    pod 'SwiftDate'
    pod 'CountryPickerSwift'
    pod 'PhoneNumberKit'
    pod 'DiffableDataSources'
    pod 'KeychainAccess'
    pod 'Permission/Location', :git => 'https://github.com/Appsaurus/Permission'
    pod 'URLNavigator'
end

def testShared
    pod 'SwiftTestUtils', :git => 'https://github.com/appsaurus/SwiftTestUtils.git'
end

target 'UIKitBase-iOS' do
    platform :ios, '10.0'
    shared
    libaryShared
end

target 'UIKitBase-iOS-Tests' do
    platform :ios, '10.0'
    shared
    testShared
    pod 'CwlPreconditionTesting', :git => 'https://github.com/mattgallagher/CwlPreconditionTesting.git', :tag => '1.2.0'
    pod 'CwlCatchException', :git => 'https://github.com/mattgallagher/CwlCatchException.git', :tag => '1.2.0'
end
