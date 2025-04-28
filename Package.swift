// swift-tools-version:5.7

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
        .library(name: "UIKitBase", targets: ["UIKitBase"]),
        .library(name: "UIKitAuthentication", targets: ["UIKitAuthentication"]),
        .library(name: "UIKitLocation", targets: ["UIKitLocation"]),
        .library(name: "UIKitForms", targets: ["UIKitForms"]),
        .library(name: "UIKitDateFields", targets: ["UIKitDateFields"]),
        .library(name: "UIKitLegalDisclosureView", targets: ["UIKitLegalDisclosureView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Appsaurus/Actions", from: "3.0.2"),
        .package(url: "https://github.com/Appsaurus/Layman", from: "1.0.0"),
        .package(url: "https://github.com/Appsaurus/UIKitMixinable", from: "1.0.0"),
        .package(url: "https://github.com/Appsaurus/UIKitTheme", from: "1.0.0"),
        .package(url: "https://github.com/Appsaurus/UIKitExtensions", from: "1.0.0"),
        .package(url: "https://github.com/Appsaurus/UIFontIcons", from: "1.0.0"),
        .package(url: "https://github.com/Appsaurus/RuntimeExtensions", from: "1.0.2"),
        .package(url: "https://github.com/Appsaurus/Swiftest", from: "1.2.7"),
        .package(url: "https://github.com/Appsaurus/DarkMagic", from: "0.0.4"),
        .package(url: "https://github.com/optonaut/ActiveLabel.swift", from: "1.1.5"),
        .package(url: "https://github.com/CosmicMind/Algorithm", from: "3.1.1"),
        .package(url: "https://github.com/ra1028/DiffableDataSources", from: "0.5.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(url: "https://github.com/kean/Nuke", from: "8.4.1"),
        .package(url: "https://github.com/malcommac/SwiftDate", from: "6.3.1"),
        .package(url: "https://github.com/devxoul/URLNavigator", from: "2.3.0"),
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
                .product(name: "DarkMagic", package: "DarkMagic"),
                .product(name: "Swiftest", package: "Swiftest"),
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
                .product(name: "KeychainAccess", package: "KeychainAccess")
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
        .target(
            name: "UIKitDateFields",
            dependencies: [
                .target(name: "UIKitForms"),
                .product(name: "SwiftDate", package: "SwiftDate")
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
                .product(name: "ActiveLabel", package: "ActiveLabel.swift")
            ],
            path: "Sources/Forms/UIKitLegalDisclosureView/",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "UIKitBaseTests",
            dependencies: [
                .target(name: "UIKitBase"),
                .product(name: "Algorithm", package: "Algorithm"),
                .product(name: "DiffableDataSources", package: "DiffableDataSources"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "RuntimeExtensions", package: "RuntimeExtensions"),
                .product(name: "Swiftest", package: "Swiftest")
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
