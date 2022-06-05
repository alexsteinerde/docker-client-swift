# Docker Client
[![Language](https://img.shields.io/badge/Swift-5.5-brightgreen.svg)](http://swift.org)
[![Docker Engine API](https://img.shields.io/badge/Docker%20Engine%20API-%20%201.41-blue)](https://docs.docker.com/engine/api/v1.41/)

This is a low-level Docker Client written in Swift. It very closely follows the Docker API.
It fully uses the Swift concurrency features introduced with Swift 5.5 (`async`/`await`).

## Docker API version support
This client library aims at implementing the Docker API version 1.41 (https://docs.docker.com/engine/api/v1.41/#)

Currently no backwards compatibility is supported; previous versions of the Docker API may or may not work.

## Current implementation status

| Section                     | Operation               | Support | Notes       |
|-----------------------------|-------------------------|---------|-------------|
| Client connection           | Local Unix socket       | ✅       |             |
|                             | HTTP                    | ✅       |             |
|                             | HTTPS + TLS client cert | 🚧       | untested    |
| Docker deamon & System info | Ping                    | ✅       |             |
|                             | Info                    | ✅       |             |
|                             | Version                 | ✅       |             |
| Containers                  | List                    | 🚧       | refactoring |
|                             | Inspect                 | 🚧       | refactoring |
|                             | Create                  | 🚧       | refactoring |
|                             | Get logs                | 🚧       | refactoring |
|                             | Exec                    | ❌       |             |
|                             | Prune                   | ✅       |             |
| Images                      | List                    | 🚧       | refactoring |
|                             | Inspect                 | 🚧       | refactoring |
|                             | Pull                    | ✅       |             |
|                             | Build                   | ❌       |             |
|                             | Prune                   | ✅       |             |
| Swarm                       | Init                    | ✅       |             |
|                             | Join                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Leave                   | ✅       |             |
|                             | Update                  | ✅       |             |
| Nodes                       | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Update                  | ✅       |             |
|                             | Delete                  | ✅       |             |
| Services                    | List                    | 🚧       | refactoring |
|                             | Inspect                 | 🚧       | refactoring |
|                             | Create                  | 🚧       | refactoring |
|                             | Get logs                | ❌       |             |
|                             | Update                  | 🚧       | refactoring |
|                             | Delete                  | ✅       |             |
| Networks                    |                         | ❌       |             |
|                             |                         |         |             |
| Volumes                     |                         | ❌       |             |
|                             |                         |         |             |
| Secrets                     |                         | ❌       |             |
|                             |                         |         |             |
| Configs                     |                         | ❌       |             |
|                             |                         |         |             |
| Tasks                       |                         | ❌       |             |
|                             |                         |         |             |
| Plugins                     |                         | ❌       |             |
|                             |                         |         |             |


## Installation
### Package.swift 
```Swift
import PackageDescription

let package = Package(
    dependencies: [
    .package(url: "https://github.com/nuw-run/docker-client-swift.git", .branch("main")),
    ],
    targets: [
    .target(name: "App", dependencies: ["DockerClient"]),
    ...
    ]
)
```

### Xcode Project
To add DockerClientSwift to your existing Xcode project, select File -> Swift Packages -> Add Package Depedancy. 
Enter `https://github.com/nuw-run/docker-client-swift.git` for the URL.


## Usage Example
```swift
let client = DockerClient()
let image = try await client.images.pullImage(byIdentifier: "hello-world:latest")
let container = try await client.containers.createContainer(image: image)
try await container.start(on: client)
let output = try await container.logs(on: client)
try client.syncShutdown()
print(output)
```

### Connect to a Docker deamon

Local socket:

Remote daemon via HTTP:

Remote daemon via HTTPS and client certificate:


### Containers


### Images


### Swarm

### Services

### Networks

### Volumes

### Secrets


## Credits
This is a fork of the great work at https://github.com/alexsteinerde/docker-client-swift

## License
This project is released under the MIT license. See [LICENSE](LICENSE) for details.


## Contribution
You can contribute to this project by submitting a detailed issue or by forking this project and sending a pull request. Contributions of any kind are very welcome :)
