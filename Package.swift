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
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.10.0"),
        // Only used for parsing the multiple and inconsistent date formats returned by Docker
        .package(url: "https://github.com/marksands/BetterCodable.git", from: "0.4.0"),
        // Some Docker features receive or return TAR archives. Used by tests
        //.package(url: "https://github.com/kayembi/Tarscape.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "DockerClientSwift",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                "BetterCodable",
            ]),
        .testTarget(
            name: "DockerClientTests",
            dependencies: [
                "DockerClientSwift",
                //"Tarscape"
            ]
        ),
    ]
)
