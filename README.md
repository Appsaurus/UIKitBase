# UIKitBase

<!-- Header Logo -->

<!-- <div align="center">
   <img width="600px" src="./Extras/banner-logo.png" alt="Banner Logo">
</div> -->


<!-- Badges -->

<p>
    <img src="https://img.shields.io/badge/Swift-5.5-F06C33.svg" />
    <img src="https://img.shields.io/badge/iOS-15.0+-865EFC.svg" />
    <img src="https://img.shields.io/badge/iPadOS-15.0+-F65EFC.svg" />
    <img src="https://img.shields.io/badge/macOS-12.0+-179AC8.svg" />
    <img src="https://img.shields.io/badge/tvOS-15.0+-41465B.svg" />
    <img src="https://img.shields.io/badge/watchOS-8.0+-1FD67A.svg" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
    <img src="https://github.com/Apppsaurus/UIKitBase/workflows/Build%20&%20Test/badge.svg" />
    <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" />
    </a>
</p>


<p align="center">

_Description + docs coming soon_

<p />


## Installation

### Xcode Projects

Select `File` -> `Swift Packages` -> `Add Package Dependency` and enter `https://github.com/Apppsaurus/UIKitBase`.


### Swift Package Manager Projects

You can add `UIKitBase` as a package dependency in your `Package.swift` file:

```swift
let package = Package(
    //...
    dependencies: [
        .package(
            name: "UIKitBase",
            url: "https://github.com/Apppsaurus/UIKitBase"
        ),
    ],
    //...
)
```


<!-- 🔑 UNCOMMENT THE INSTRUCTIONS BELOW IF THE GITHUB REPO NAME MATCHES THE LIBRARY NAME 👇 -->

<!-- From there, refer to `UIKitBase` as a "target dependency" in any of _your_ package's targets that need it.

```swift
targets: [
    .target(
        name: "UIKitBase",
        dependencies: [
          "UIKitBase",
        ],
        ...
    ),
    ...
]
``` -->

<!-- 🔑 UNCOMMENT THE INSTRUCTIONS BELOW IF THE GITHUB REPO NAME DOESN'T MATCH THE LIBRARY NAME 👇 -->

From there, refer to the `UIKitBase` "product" delivered by the `UIKitBase` "package" inside of any of your project's target dependencies:

```swift
targets: [
    .target(
        name: "UIKitBase",
        dependencies: [
            .product(
                name: "UIKitBase",
                package: "UIKitBase"
            ),
        ],
        ...
    ),
    ...
]
```

<!-- Proceed from above choice accordingly (and delete this comment) -->

Then simply `import UIKitBase` wherever you’d like to use it.


<!--
    🔑 UNCOMMENT THE INSTRUCTIONS BELOW IF USING THE `@_exported` feature
    might be handy. 👇
-->

<!-- **📝 Note:** To make the library available to your entire project, you could also leverage the [functionality of the `@_exported` keyword](https://forums.swift.org/t/package-manager-exported-dependencies/11615) by placing the following line somewhere at the top level of your project:

```swift
@_exported import UIKitBase
``` -->


## Usage



## 🗺 Roadmap

- World Domination



## Contributing

Contributions to `UIKitBase` are most welcome. Check out some of the [issue templates](./.github/ISSUE_TEMPLATE/) for more info.



## 💻 Developing

### Requirements

- Xcode 13.0+


### 📜 Creating & Building Documentation

Documentation is built with [Xcode's DocC](https://developer.apple.com/documentation/docc). See [Apple's guidance on how to build, run, and create DocC content](https://developer.apple.com/documentation/docc/api-reference-syntax).

For now, the best way to view the docs is to open the project in Xcode and run the `Build Documentation` command. At some point in the future, I'm hoping to leverage the tooling the develops for generating/hosting DocC documentation. (Please feel free to let me know if you have any ideas or tooling recommendations around this 🙂).


## 🏷 License

`UIKitBase` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.
