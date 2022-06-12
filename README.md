# Docker Client
[![Language](https://img.shields.io/badge/Swift-5.5-brightgreen.svg)](http://swift.org)
[![Docker Engine API](https://img.shields.io/badge/Docker%20Engine%20API-%20%201.41-blue)](https://docs.docker.com/engine/api/v1.41/)

This is a low-level, **work in progress** Docker Client written in Swift. It very closely follows the Docker API.

It fully uses the Swift concurrency features introduced with Swift 5.5 (`async`/`await`).


## Docker API version support
This client library aims at implementing the Docker API version 1.41 (https://docs.docker.com/engine/api/v1.41/#)

Currently no backwards compatibility is supported; previous versions of the Docker API may or may not work.

## Current implementation status

| Section                     | Operation               | Support | Notes       |
|-----------------------------|-------------------------|---------|-------------|
| Client connection           | Local Unix socket       | ✅       |             |
|                             | HTTP                    | ✅       |             |
|                             | HTTPS + TLS client cert | 🚧       | untested, WIP |
| Docker deamon & System info | Ping                    | ✅       |             |
|                             | Info                    | ✅       |             |
|                             | Version                 | ✅       |             |
|                             | Events                  | ❌       |      TBD    |
|                             | Get disk usage info     | ❌       |      TBD    |
| Containers                  | List                    | 🚧       | refactoring |
|                             | Inspect                 | ✅       | refactoring |
|                             | Create                  | 🚧       | refactoring |
|                             | Update                  | ❌       |      TBD    |
|                             | Rename                  | ❌       |      TBD    |
|                             | Pause/Unpause           | ❌       |      TBD    |
|                             | Get logs                | ✅       |             |
|                             | Get stats               | ❌       |      TBD    |
|                             | Get process (top)       | ❌       |      TBD    |
|                             | Prune                   | ✅       |             |
|                             | Attach                  | ❌       |      TBD    |
|                             | Exec                    | ❌       |  unlikely           |
| Images                      | List                    | ✅       |             |
|                             | Inspect                 | 🚧       | refactoring |
|                             | Pull                    | ✅       | refactoring |
|                             | Build                   | ❌       |      TBD       |
|                             | Tag                     | ❌       |      TBD       |
|                             | Push                    | ❌       |      TBD       |
|                             | Create (container commit)| ❌       |             |
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
| Services                    | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Create                  | ✅       |             |
|                             | Get logs                | ✅       |             |
|                             | Update                  | 🚧       | refactoring |
|                             | Rollback                | ✅       |             |
|                             | Delete                  | ✅       |             |
| Networks                    |                         | ❌       |    TBD         |
|                             |                         |         |             |
| Volumes                     |                         | ❌       |     TBD        |
|                             |                         |         |             |
| Secrets                     |                         | ❌       |     TBD        |
|                             |                         |         |             |
| Configs                     |                         | ❌       |   TBD          |
|                             |                         |         |             |
| Tasks                       | List                    | ❌       |    TBD         |
|                             | Inspect                 | ❌       |    TBD     |
|                             | Get logs                | 🚧       |             |
|                             |                         |          |             |
| Plugins                     |                         | ❌       |    TBD         |
|                             |                         |         |             |
| Registries                  |                         | ❌       |     TBD        |
|                             |                         |         |             |


✅ : done or _mostly_ done

🚧 : work in progress, partially implemented, might not work

❌ : not implemented/supported at the moment.


## Installation
### Package.swift 
```Swift
import PackageDescription

let package = Package(
    dependencies: [
        .package(url: "https://github.com/nuw-run/docker-client-swift.git", .branch("main")),
    ],
    targets: [
        .target(name: "App", dependencies: [
            ...
            .product(name: "DockerClientSwift", package: "docker-client-swift")
        ]),
    ...
    ]
)
```

### Xcode Project
To add DockerClientSwift to your existing Xcode project, select File -> Swift Packages -> Add Package Depedancy. 
Enter `https://github.com/nuw-run/docker-client-swift.git` for the URL.


## Usage Examples

### Connect to a Docker deamon

Local socket (defaults to `/var/run/docker.sock`):
```swift
let docker = DockerClient()
```

Remote daemon via HTTP:
```swift
let docker = DockerClient(deamonURL: .init(string: "http://127.0.0.1:2375")!)
```

Remote daemon via HTTPS and client certificate:


### Docker system info

<details>
  <summary>Get detailed information about the Docker daemon</summary>
  
  ```swift
  let info = try await docker.info()
  print("• Docker daemon info: \(info)")
  ```
</details>

<details>
  <summary>Get versions information about the Docker daemon</summary>
  
  ```swift
  let version = try await docker.version()
  print("• Docker API version: \(version.apiVersion)")
  ```
</details>

 
### Containers

<details>
  <summary>List containers</summary>
  
  Add `all: true` to also return stopped containers.
  ```swift
  let containers = try await docker.containers.list()
  ```
</details>

<details>
  <summary>Get a container details</summary>
  
  ```swift
  let container = try await docker.containers.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a container: basic</summary>
  
  ```swift
  let image = try await docker.images.pullImage(byName: "hello-world", tag: "latest")
  let id = try await docker.containers.create(image: image)
  ```
</details>

<details>
  <summary>Create a container: advanced</summary>
  
  ```swift
  let spec = ContainerCreate(
      config: ContainerConfig(
          image: "hello-world:latest",
          ...
      ),
      hostConfig: ContainerHostConfig(
          ...
      )
  )
  let id = try await docker.containers.create(name: "test", spec: spec)
  ```
</details>

<details>
  <summary>Create and start a container</summary>
  
  ```swift
  let spec = ContainerCreate(
      config: ContainerConfig(image: "hello-world:latest"),
      hostConfig: ContainerHostConfig()
  )
  let id = try await docker.containers.create(name: "tests", spec: spec)
  try await docker.containers.start(id)
  ```
</details>

<details>
  <summary>Stop a container</summary>
  
  ```swift
  try await client.containers.stop("xxxxxxx")
  ```
</details>

<details>
  <summary>Delete a container</summary>
  
  If the container is running, deletion can be forced by passing `force: true` 
  ```swift
  try await docker.containers.remove("xxxxxxx")
  ```
</details>

<details>
  <summary>Get container logs</summary>
  
  Logs are streamed progressively in an asynchronous way.
  ```swift
  let container = try await docker.containers.get("nameOrId")
        
  for try await line in try await docker.containers.logs(container: container, timestamps: true) {
      print(line.message + "\n")
  }
  ```
</details>

### Images

<details>
  <summary>List the Docker images</summary>
  
  ```swift
  let images = try await docker.images.list()
  ```
</details>

<details>
  <summary>Pull an image</summary>
  
  ```swift
  let image = try await docker.images.pullImage(byIdentifier: "hello-world:latest")
  ```
</details>

### Swarm

<details>
  <summary>Initialize Swarm mode</summary>
  
  ```swift
  let swarmId = try await docker.swarm.initSwarm()
  ```
</details>

<details>
  <summary>Get Swarm cluster details (inspect)</summary>
  
  Note: Must be connected to a manager node.
  ```swift
  let swarm = try await docker.swarm.get()
  ```
</details>

<details>
  <summary>Remove the current Node from the Swarm</summary>
  
  Note: `force` is needed if the node is a manager
  ```swift
  try await docker.swarm.leave(force: true)
  ```
</details>

### Nodes
<details>
  <summary>List the Swarm nodes</summary>
  
  ```swift
  let nodes = try await docker.nodes.list()
  ```
</details>

<details>
  <summary>Remove a Node from a Swarm</summary>
  
  Note: `force` is needed if the node is a manager
  ```swift
  try await docker.nodes.delete(id: "xxxxxx", force: true)
  ```
</details>


### Services
Note: Must be connected to a manager node.

<details>
  <summary>List services</summary>
  
  ```swift
  let services = try await docker.services.list()
  ```
</details>

<details>
  <summary>Get a service details</summary>
  
  ```swift
  let service = try await docker.services.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a service</summary>
  
  Simplest possible example, we just specify the image and a number of replicas:
  ```swift
  let spec = ServiceSpec(
      name: "my-nginx",
      taskTemplate: .init(
          containerSpec: .init(image: "nginx:latest")
      ),
      mode: .init(
          replicated: .init(replicas: 1)
      )
  )
  let id = try await docker.services.create(spec: spec)
  ```
  
  Let's specify a memory limit of 64MB for our service containers:
  ```swift
  let spec = ServiceSpec(
      name: "my-nginx",
      taskTemplate: .init(
          containerSpec: .init(image: "nginx:latest"),
          resources: .init(
              limits: .init(memoryBytes: UInt64(64 * 1024 * 1024))
          )
      ),
      mode: .init(
          replicated: .init(replicas: 1)
      )
  )
  let id = try await docker.services.create(spec: spec)
  ```
  TODO: add examples for specifying networks and volumes
</details>
        

<details>
  <summary>Get service logs</summary>
  
  Logs are streamed progressively in an asynchronous way.
  ```swift
  let service = try await docker.services.get("nameOrId")
        
  for try await line in try await docker.services.logs(service: service) {
      print(line.message + "\n")
  }
  ```
</details>


<details>
  <summary>Rollback a service</summary>
  
  Suppose that we updated our existing service configuration, and something is not working properly.
  We want to revert back to the previous, working version.
  ```swift
  try await docker.services.rollback("nameOrId")
  ```
</details>

<details>
  <summary>Delete a service</summary>
  
  ```swift
  try await docker.services.remove("nameOrId")
  ```
</details>

### Networks

### Volumes

### Secrets


## Credits
This is a fork of the great work at https://github.com/alexsteinerde/docker-client-swift

## License
This project is released under the MIT license. See [LICENSE](LICENSE) for details.


## Contribution
You can contribute to this project by submitting a detailed issue or by forking this project and sending a pull request. Contributions of any kind are very welcome :)
