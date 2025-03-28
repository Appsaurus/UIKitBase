// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "UIKitBase",
    platforms: [
        .iOS(.v13),
//        .macOS(.v12),
//        .tvOS(.v15),
//        .watchOS(.v8),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "UIKitBase",
            targets: ["UIKitBase"]
        ),
        .library(
            name: "UIKitAuthentication",
            targets: ["UIKitAuthentication"]
        ),
        .library(
            name: "UIKitLocation",
            targets: ["UIKitLocation"]
        ),
        .library(
            name: "UIKitForms",
            targets: ["UIKitForms"]
        ),
//        .library(
//            name: "UIKitAuthenticationForms",
//            targets: ["UIKitAuthenticationForms"]
//        ),
        .library(
            name: "UIKitDateFields",
            targets: ["UIKitDateFields"]
        ),
        .library(
            name: "UIKitLegalDisclosureView",
            targets: ["UIKitLegalDisclosureView"]
        ),
//        .library(
//            name: "UIKitLocationForms",
//            targets: ["UIKitLocationForms"]
//        )
    ],
    dependencies: [
//        // Internal packages
        .package(name: "Actions", url: "https://github.com/Appsaurus/Actions", from: "3.0.2"),
        .package(name: "Layman", url: "https://github.com/Appsaurus/Layman", from: "1.0.0"),
        .package(name: "UIKitMixinable", url: "https://github.com/Appsaurus/UIKitMixinable", from: "1.0.0"),
        .package(name: "UIKitTheme", url: "https://github.com/Appsaurus/UIKitTheme", from: "1.0.0"),
        .package(name: "UIKitExtensions", url: "https://github.com/Appsaurus/UIKitExtensions", from: "1.0.0"),
        .package(name: "UIFontIcons", url: "https://github.com/Appsaurus/UIFontIcons", from: "1.0.0"),
        .package(name: "RuntimeExtensions", url: "https://github.com/Appsaurus/RuntimeExtensions", from: "1.0.2"),
        .package(name: "Swiftest", url: "https://github.com/Appsaurus/Swiftest", from: "1.2.3"),

        //  Open Source
        .package(name: "ActiveLabel", url: "https://github.com/optonaut/ActiveLabel.swift", from: "1.1.5"),
        .package(name: "Algorithm", url: "https://github.com/CosmicMind/Algorithm", from: "3.1.1"),

        //CountryCode needs to fix spm integration - https://github.com/4taras4/CountryCode/issues/62
//        .package(name: "CountryCode", url: "https://github.com/4taras4/CountryCode", from: "1.8.2"),
        .package(name: "DiffableDataSources", url: "https://github.com/ra1028/DiffableDataSources", from: "0.5.0"),
        .package(name: "KeychainAccess", url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(name: "Nuke", url: "https://github.com/kean/Nuke", from: "8.4.1"),
//        .package(name: "PhoneNumberKit", url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.3.0"),
        .package(name: "SwiftDate", url: "https://github.com/malcommac/SwiftDate", from: "6.3.1"),
        .package(name: "URLNavigator", url: "https://github.com/devxoul/URLNavigator", from: "2.3.0"),
        .package(name: "SFSafeSymbols", url: "https://github.com/SFSafeSymbols/SFSafeSymbols", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "UIKitBase",
            dependencies: [
                .product(name: "Actions", package: "Actions"),
                .product(name: "Algorithm", package: "Algorithm"),
                .product(name: "DiffableDataSources", package: "DiffableDataSources"),
                .product(name: "Layman", package: "Layman"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "RuntimeExtensions", package: "RuntimeExtensions"),
                .product(name: "Swiftest", package: "Swiftest"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "UIKitTheme", package: "UIKitTheme"),
                .product(name: "UIKitMixinable", package: "UIKitMixinable"),
                .product(name: "UIKitExtensions", package: "UIKitExtensions"),
                .product(name: "UIFontIcons", package: "UIFontIcons"),
                .product(name: "URLNavigator", package: "URLNavigator")
                ],
            path: "Sources/UIKitBase/",
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "UIKitAuthentication",
            dependencies: [
                .target(name: "UIKitBase"),
                "KeychainAccess"
            ],
            path: "Sources/UIKitAuthentication/",
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "UIKitLocation",
            dependencies: [
                .target(name: "UIKitBase"),
            ],
            path: "Sources/UIKitLocation/",
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "UIKitForms",
            dependencies: [
                .target(name: "UIKitBase"),
            ],
            path: "Sources/Forms/UIKitForms/",
            resources: [
                .process("Resources"),
            ]
        ),
        //CountryCode needs to fix spm integration - https://github.com/4taras4/CountryCode/issues/62
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
        .target(
            name: "UIKitDateFields",
            dependencies: [
                .target(name: "UIKitForms"),
                "SwiftDate"
            ],
            path: "Sources/Forms/UIKitDateFields/",
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "UIKitLegalDisclosureView",
            dependencies: [
                .target(name: "UIKitForms"),
                "ActiveLabel"
            ],
            path: "Sources/Forms/UIKitLegalDisclosureView/",
            resources: [
                .process("Resources"),
            ]
        ),
        //Need to replace Permissions dependency
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
