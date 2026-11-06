// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BlockBlast",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BlockBlastLib",
            targets: ["BlockBlastLib"]
        )
    ],
    targets: [
        .target(
            name: "BlockBlastLib",
            path: "Sources",
            exclude: ["App/BlockBlastApp.swift"]
        ),
        .testTarget(
            name: "BlockBlastTests",
            dependencies: ["BlockBlastLib"],
            path: "Tests"
        )
    ]
)
