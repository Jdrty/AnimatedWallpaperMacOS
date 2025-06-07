// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AnimatedWallpaper",
    platforms: [
        .macOS(.v11)
    ],
    targets: [
        .executableTarget(
            name: "AnimatedWallpaper",
            dependencies: [],
            path: "Sources/AnimatedWallpaper"
        )
    ]
)
