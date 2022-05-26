// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "aes-ige-swift",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "AESIGE",
            targets: ["AESIGE"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AESIGE",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "AESIGETests",
            dependencies: ["AESIGE"]),
    ]
)
