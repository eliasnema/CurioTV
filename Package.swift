// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CurioTV",
    platforms: [.tvOS(.v26), .macOS(.v26)],
    products: [.library(name: "CurioCore", targets: ["CurioCore"])],
    targets: [
        .target(name: "CurioCore", resources: [.process("Resources")]),
        .testTarget(name: "CurioCoreTests", dependencies: ["CurioCore"], resources: [.process("Fixtures")])
    ]
)
