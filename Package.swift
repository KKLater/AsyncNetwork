// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncNetwork",
    platforms: [
        .macOS(.v10_12), .iOS(.v11), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(
            name: "AsyncNetwork",
            targets: ["AsyncNetwork"]
        ),
        .library(
            name: "AsyncNetworkKit",
            targets: [
                "AsyncNetwork"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
        .package(url: "https://github.com/KKLater/Async.git", from: "0.0.2"),
    ],
    targets: [
        .target(
            name: "AsyncNetwork",
            dependencies: [
                "Alamofire",
                .productItem(name: "AsyncKit", package: "Async")
            ]
        ),
        .testTarget(
            name: "AsyncNetworkTests",
            dependencies: [
                "AsyncNetwork",
                .productItem(name: "AsyncKit", package: "Async")
            ]),
    ]
)
