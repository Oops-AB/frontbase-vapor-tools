// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "frontbase-vapor-tools",
    platforms: [
       .macOS(.v12),
    ],
    products: [
        .library(
            name: "ConnectionPoolConcurrency",
            targets: ["ConnectionPoolConcurrency"]),
        .library(
            name: "FrontbaseConnectionPool",
            targets: ["FrontbaseConnectionPool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/Oops-AB/Frontbase", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "ConnectionPoolConcurrency",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ]),
        .target(
            name: "FrontbaseConnectionPool",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Frontbase", package: "Frontbase"),
                .target(name: "ConnectionPoolConcurrency")
            ]),
    ]
)
