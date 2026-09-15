// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DaroodTracker",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "DaroodTracker", targets: ["DaroodTracker"])
    ],
    targets: [
        .executableTarget(
            name: "DaroodTracker",
            path: "Sources"
        )
    ]
)
