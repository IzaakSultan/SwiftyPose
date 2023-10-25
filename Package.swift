// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftyPose",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftyPose",
            targets: ["SwiftyPose"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6")
    ],
    targets: [
        .target(
            name: "SwiftyPose",
            dependencies: ["Yams"]),
        .testTarget(
            name: "SwiftyPoseTests",
            dependencies: ["SwiftyPose"]),
    ]
)
