// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "docker-client-swift",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "DockerClientSwift", targets: ["DockerClientSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.18.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "DockerClientSwift",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]),
        .testTarget(
            name: "DockerClientTests",
            dependencies: ["DockerClientSwift"]
        ),
    ]
)
