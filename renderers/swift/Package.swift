// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "A2UI",
    platforms: [
		.iOS(.v18),
		.macOS(.v15)
    ],
    products: [
        .library(
            name: "A2UI",
            targets: ["A2UI"]),
    ],
    targets: [
        .target(
            name: "A2UI",
            dependencies: []),
        .testTarget(
            name: "A2UITests",
            dependencies: ["A2UI"]),
    ]
)
