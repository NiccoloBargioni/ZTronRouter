// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZTronRouter",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZTronRouter",
            targets: ["ZTronRouter"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/NickTheFreak97/ztron-routing-kit.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZTronRouter",
            dependencies: [
                .product(name: "ZTronRoutingKit", package: "ztron-routing-kit"),
            ]
        ),
        .testTarget(
            name: "ZTronRouterTests",
            dependencies: [
                "ZTronRouter",
                .product(name: "ZTronRoutingKit", package: "ztron-routing-kit"),
            ]
        )
    ]
)
