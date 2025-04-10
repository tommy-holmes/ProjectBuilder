// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ProjectBuilder",
    platforms: [
        .macOS("13.0")
    ],
    dependencies: [
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", .upToNextMajor(from: "2.42.0")),
    ],
    targets: [
        .executableTarget(
            name: "ProjectBuilder",
            dependencies: [
                .product(name: "XcodeGenKit", package: "XcodeGen"),
            ]
        ),
    ]
)
