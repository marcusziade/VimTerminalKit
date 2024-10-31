// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VimTerminalKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
        .watchOS(.v9),
        .tvOS(.v15),
    ],
    products: [
        .library(
            name: "VimTerminalKit",
            targets: ["VimTerminalKit"]
        ),
        .executable(
            name: "FileExplorer",
            targets: ["FileExplorer"]
        )
    ],
    targets: [
        .target(
            name: "VimTerminalKit"),
        .testTarget(
            name: "VimTerminalKitTests",
            dependencies: ["VimTerminalKit"]
        ),
        .executableTarget(
            name: "FileExplorer",
            dependencies: ["VimTerminalKit"]
        )
    ]
)
