// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "UIKitBase",
    platforms: [
        .iOS(.v11),
//        .macOS(.v12),
//        .tvOS(.v15),
//        .watchOS(.v8),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "UIKitBase",
            targets: [
                "UIKitBase",
//                "UIKitAuthentication",
//                "UIKitDatasource",
//                "UIKitLocation",
//                "UIKitForms",
//                "UIKitAuthenticationForms",
//                "UIKitDateFields",
//                "UIKitLegalDisclosureView",
//                "UIKitLocationForms",
            ]
        ),
    ],
    dependencies: [

//        // Internal packages
//        .package(url: "https://github.com/Appsaurus/Layman", .branch("spm")),
////        .package(url: "https://github.com/Appsaurus/RuntimeExtensions", .branch("spm")),
////        .package(url: "https://github.com/Appsaurus/Swiftest", .branch("spm")),
//            .package(url: "https://github.com/Appsaurus/UIKitMixinable", .branch("spm")),
//        .package(url: "https://github.com/Appsaurus/UIKitTheme", .branch("spm")),
//        .package(url: "https://github.com/Appsaurus/UIKitExtensions", .branch("spm")),
//        .package(url: "https://github.com/Appsaurus/UIFontIcons", .branch("spm")),
////        .package(name: "Layman", url: "https://github.com/Appsaurus/Layman", from: "0.1.26"),
//        .package(url: "https://github.com/Appsaurus/RuntimeExtensions", .branch("master")),
////        .package(name: "RuntimeExtensions", url: "https://github.com/Appsaurus/RuntimeExtensions", from: "0.1.14"),
//        .package(url: "https://github.com/Appsaurus/Swiftest", .branch("master")),
////        .package(name: "Swiftest", url: "https://github.com/Appsaurus/Swiftest", from: "0.0.1"),
////        .package(name: "UIKitMixinable", url: "https://github.com/Appsaurus/UIKitMixinable", from: "0.1.1"),
////        .package(name: "UIKitTheme", url: "https://github.com/Appsaurus/UIKitTheme", from: "0.0.30"),
////        .package(name: "UIKitExtensions", url: "https://github.com/Appsaurus/UIKitExtensions", from: "0.0.36"),
////        .package(name: "UIFontIcons", url: "https://github.com/Appsaurus/UIFontIcons", from: "0.0.6"),
//
//        //  Open Source
//            .package(url: "https://github.com/optonaut/ActiveLabel.swift", .upToNextMajor(from: "1.1.5")),
//        .package(url: "https://github.com/CosmicMind/Algorithm", .upToNextMajor(from: "3.1.1")),
//        .package(url: "https://github.com/woxtu/AssistantKit", .branch("spm")),
//
////            .package(url: "https://github.com/4taras4/CountryCode", .upToNextMajor(from: "1.8.2")),
//        .package(url: "https://github.com/ra1028/DiffableDataSources", .upToNextMajor(from: "0.5.0")),
//        .package(url: "https://github.com/ra1028/DifferenceKit.git", .upToNextMajor(from: "1.2.0")),
//        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "4.2.2")),
//
//
//            .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "8.4.1")),
//        .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "3.3.0")),
//        .package(url: "https://github.com/malcommac/SwiftDate", .upToNextMajor(from: "6.3.1")),
////        .package(url: "https://github.com/devxoul/URLNavigator", .upToNextMajor(from: "2.3.0")),
//        // Internal packages
        .package(name: "Layman", url: "https://github.com/Appsaurus/Layman", branch: "spm"),
//        .package(name: "RuntimeExtensions", url: "https://github.com/Appsaurus/RuntimeExtensions", branch: "spm"),
//        .package(name: "Swiftest", url: "https://github.com/Appsaurus/Swiftest", branch: "spm"),
        .package(name: "UIKitMixinable", url: "https://github.com/Appsaurus/UIKitMixinable", branch: "spm"),
        .package(name: "UIKitTheme", url: "https://github.com/Appsaurus/UIKitTheme", branch: "spm"),
        .package(name: "UIKitExtensions", url: "https://github.com/Appsaurus/UIKitExtensions", branch: "spm"),
        .package(name: "UIFontIcons", url: "https://github.com/Appsaurus/UIFontIcons", branch: "spm"),
//        .package(name: "Layman", url: "https://github.com/Appsaurus/Layman", from: "0.1.26"),
        .package(name: "RuntimeExtensions", url: "https://github.com/Appsaurus/RuntimeExtensions", branch: "master"),
//        .package(name: "RuntimeExtensions", url: "https://github.com/Appsaurus/RuntimeExtensions", from: "0.1.14"),
        .package(name: "Swiftest", url: "https://github.com/Appsaurus/Swiftest", branch: "master"),
//        .package(name: "Swiftest", url: "https://github.com/Appsaurus/Swiftest", from: "0.0.1"),
//        .package(name: "UIKitMixinable", url: "https://github.com/Appsaurus/UIKitMixinable", from: "0.1.1"),
//        .package(name: "UIKitTheme", url: "https://github.com/Appsaurus/UIKitTheme", from: "0.0.30"),
//        .package(name: "UIKitExtensions", url: "https://github.com/Appsaurus/UIKitExtensions", from: "0.0.36"),
//        .package(name: "UIFontIcons", url: "https://github.com/Appsaurus/UIFontIcons", from: "0.0.6"),

        //  Open Source
        .package(name: "ActiveLabel", url: "https://github.com/optonaut/ActiveLabel.swift", from: "1.1.5"),
        .package(name: "Algorithm", url: "https://github.com/CosmicMind/Algorithm", from: "3.1.1"),
        .package(name: "AssistantKit", url: "https://github.com/woxtu/AssistantKit", branch: "spm"),

//        .package(name: "CountryCode", url: "https://github.com/4taras4/CountryCode", from: "1.8.2"),
        .package(name: "DiffableDataSources", url: "https://github.com/ra1028/DiffableDataSources", from: "0.5.0"),
        .package(name: "DifferenceKit", url: "https://github.com/ra1028/DifferenceKit.git", from: "1.2.0"),
        .package(name: "KeychainAccess", url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),


        .package(name: "Nuke", url: "https://github.com/kean/Nuke", from: "8.4.1"),
        .package(name: "PhoneNumberKit", url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.3.0"),
        .package(name: "SwiftDate", url: "https://github.com/malcommac/SwiftDate", from: "6.3.1"),
        .package(name: "URLNavigator", url: "https://github.com/devxoul/URLNavigator", from: "2.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "UIKitBase",
            dependencies: [
                .product(name: "Algorithm", package: "Algorithm"),
                .product(name: "AssistantKit", package: "AssistantKit"),
                .product(name: "DiffableDataSources", package: "DiffableDataSources"),
                .product(name: "Layman", package: "Layman"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "RuntimeExtensions", package: "RuntimeExtensions"),
                .product(name: "Swiftest", package: "Swiftest"),
                .product(name: "UIKitTheme", package: "UIKitTheme"),
                .product(name: "UIKitMixinable", package: "UIKitMixinable"),
                .product(name: "UIKitExtensions", package: "UIKitExtensions"),
                .product(name: "UIFontIcons", package: "UIFontIcons"),
                .product(name: "URLNavigator", package: "URLNavigator")            ],
            path: "Sources/UIKitBase/",
            resources: [
                .process("Resources"),
            ]
        ),
//        .target(
//            name: "UIKitAuthentication",
//            dependencies: [
//                .target(name: "UIKitBase"),
//                "KeychainAccess"
//            ],
//            path: "Sources/UIKitAuthentication/",
//            resources: [
//                .process("Resources"),
//            ]
//        ),
//        .target(
//            name: "UIKitDatasource",
//            dependencies: [
//                .target(name: "UIKitBase"),
//                "DiffableDataSources"
//            ],
//            path: "Sources/UIKitDatasource/",
//            resources: [
//                .process("Resources"),
//            ]
//        ),
//        .target(
//            name: "UIKitLocation",
//            dependencies: [
//                .target(name: "UIKitBase"),
//            ],
//            path: "Sources/UIKitLocation/",
//            resources: [
//                .process("Resources"),
//            ]
//        ),
//        .target(
//            name: "UIKitForms",
//            dependencies: [
//                .target(name: "UIKitBase"),
//            ],
//            path: "Sources/Forms/UIKitForms/",
//            resources: [
//                .process("Resources"),
//            ]
//        ),
//        .target(
//            name: "UIKitAuthenticationForms",
//            dependencies: [
//                .target(name: "UIKitForms"),
//                "CountryCode",
//                "PhoneNumberKit"
//            ],
//            path: "Sources/Forms/UIKitAuthenticationForms/",
//            resources: [
//                .process("Resources"),
//            ]
//        ),
//        .target(
//            name: "UIKitDateFields",
//            dependencies: [
//                .target(name: "UIKitForms"),
//                "SwiftDate"
//            ],
//            path: "Sources/Forms/UIKitDateFields/",
//            resources: [
//                .process("Resources"),
//            ]
//        ),
//        .target(
//            name: "UIKitLegalDisclosureView",
//            dependencies: [
//                .target(name: "UIKitForms"),
//                "ActiveLabel"
//            ],
//            path: "Sources/Forms/UIKitLegalDisclosureView/",
//            resources: [
//                .process("Resources"),
//            ]
//        ),
//        .target(
//            name: "UIKitLocationForms",
//            dependencies: [
//                .target(name: "UIKitForms")
//            ],
//            path: "Sources/Forms/UIKitLocationForms/",
//            resources: [
//                .process("Resources"),
//            ]
//        ),
        .testTarget(
            name: "UIKitBaseTests",
            dependencies: [
                .target(name: "UIKitBase"),
                "Algorithm",
                "AssistantKit",
                "DiffableDataSources",
                "Nuke",
                "RuntimeExtensions",
                "Swiftest"
            ],
            path: "Tests/UIKitBase/",
            exclude: [
                "Resources/README.md",
                "Toolbox/README.md",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
