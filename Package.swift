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
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.5.1"))
    ],
    targets: [
        .target(
            name: "AESIGE",
            dependencies: [
                "CryptoSwift"
            ]
        ),
        .testTarget(
            name: "AESIGETests",
            dependencies: ["AESIGE"]),
    ]
)
