// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Combined",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Combined",
            type: .dynamic,
            targets: ["Combined"]
        ),
    ],
    dependencies: [
        .package(path: "../../MyLib")
    ],
    targets: [
        .target(
            name: "Combined",
            dependencies: [
                .product(
                    name: "MyLib",
                    package: "MyLib"
                )
            ]
        ),
    ]
)
