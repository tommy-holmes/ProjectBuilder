// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ProjectBuilder",
    platforms: [
        .macOS("13.0")
    ],
    targets: [
        .executableTarget(
            name: "ProjectBuilder",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
