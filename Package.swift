// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NanoKontrolTwo",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "NanoKontrolTwo",
            targets: ["NanoKontrolTwo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mkj-is/CombineMIDI.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "NanoKontrolTwo",
            dependencies: ["CombineMIDI"]),
    ]
)
