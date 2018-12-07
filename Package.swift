// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "UIKitBase",
	products: [
		.library(name: "UIKitBase", targets: ["UIKitBase"])
	],
	dependencies: [],
	targets: [
	.target(name: "UIKitBase", dependencies: [], path: "Sources/Shared"),
		.testTarget(name: "UIKitBaseTests", dependencies: ["UIKitBase"], path: "UIKitBaseTests/Shared")
	]
)
