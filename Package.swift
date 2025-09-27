// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-logger",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Logger",
            targets: ["Logger"]),
    ],
    targets: [
        .target(name: "Logger"),
    ]
)
