// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VimTerminalKit",
    products: [
        .library(
            name: "VimTerminalKit",
            targets: ["VimTerminalKit"]
        )
    ],
    targets: [
        .target(
            name: "VimTerminalKit"),
        .testTarget(
            name: "VimTerminalKitTests",
            dependencies: ["VimTerminalKit"]
        ),
    ]
)
