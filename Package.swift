// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AnimatedWallpaper",
    platforms: [.macOS(.v11)],
    targets: [

        // helper that extracts a frame
        .executableTarget(
            name: "CaptureFrame",
            path: "Sources/CaptureFrame"
        ),

        // main app
        .executableTarget(
            name: "AnimatedWallpaper",
            dependencies: [],
            path: "Sources/AnimatedWallpaper"
        )
    ]
)
