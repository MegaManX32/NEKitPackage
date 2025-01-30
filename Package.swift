// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NEKitPackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NEKitPackage",
            targets: ["NEKitPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/behrang/YamlSwift.git", .upToNextMajor(from: "3.4.4")),
        .package(url: "https://github.com/jedisct1/swift-sodium.git", .upToNextMajor(from: "0.9.1")),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", .upToNextMajor(from: "3.8.5")),
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", .upToNextMajor(from: "7.6.5")),
        .package(url: "https://github.com/zhuhaow/Resolver.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/zhuhaow/tun2socks.git", .upToNextMajor(from: "0.8.0")),
    ],
    targets: [
        .target(
            name: "NEKitPackage",
            dependencies: [
                .product(name: "Yaml", package:"yamlswift"),
                .product(name: "Sodium", package: "swift-sodium"),
                .product(name: "CocoaLumberjackSwift", package: "cocoalumberjack"),
                .product(name: "CocoaAsyncSocket", package: "cocoaasyncsocket"),
                .product(name: "Resolver", package: "resolver"),
                .product(name: "tun2socks", package: "tun2socks")
            ]
        )
    ]
)

