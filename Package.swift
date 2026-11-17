// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Countdown",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Countdown", path: "Sources/Countdown"),
        .testTarget(name: "CountdownTests", dependencies: ["Countdown"], path: "Tests/CountdownTests"),
    ]
)
