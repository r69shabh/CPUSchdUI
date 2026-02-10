// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CPUSchedulerUI",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "CPUSchedulerUI",
            path: "CPUSchedulerUI",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
