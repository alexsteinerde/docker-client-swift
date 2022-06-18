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
|                             | HTTPS + TLS client cert | 🚧       | WIP         |
|                             |                         |          |             |
| Docker deamon & System info | Ping                    | ✅       |             |
|                             | Info                    | ✅       |             |
|                             | Version                 | ✅       |             |
|                             | Events                  | ✅       |             |
|                             | Get data usage info     | ✅       |             |
|                             |                         |          |             |
| Containers                  | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Create                  | ✅       |             |
|                             | Update                  | ✅       |             |
|                             | Rename                  | ✅       |             |
|                             | Pause/Unpause           | ✅       |             |
|                             | Get logs                | ✅       |             |
|                             | Get stats               | ❌       |      TBD    |
|                             | Get processes (top)     | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             | Prune                   | ✅       |             |
|                             | Wait                    | ✅       |   untested  |
|                             | Filesystem changes      | ✅       |   untested  |
|                             | Attach                  | ❌       |      TBD    |
|                             | Exec                    | ❌       |  unlikely   |
|                             |                         |          |             |
| Images                      | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | History                 | ✅       |             |
|                             | Pull                    | ✅       | refactoring |
|                             | Build                   | ✅       | basic implementation |
|                             | Tag                     | ✅       |             |
|                             | Push                    | ✅       |             |
|                             | Create (container commit)| ❌       |             |
|                             | Delete                  | ✅       |             |
|                             | Prune                   | ✅       |             |
|                             |                         |          |             |
| Swarm                       | Init                    | ✅       |             |
|                             | Join                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Leave                   | ✅       |             |
|                             | Update                  | ✅       |             |
|                             |                         |          |             |
| Nodes                       | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Update                  | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             |                         |          |             |
| Services                    | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Create                  | ✅       |             |
|                             | Get logs                | ✅       |             |
|                             | Update                  | 🚧       | refactoring |
|                             | Rollback                | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             |                         |          |             |
| Networks                    | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Create                  | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             | Prune                   | ✅       |             |
|                             | Connect/Disconnect container| ❌       |    TBD      |
|                             |                         |          |             |
| Volumes                     | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Create                  | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             | Prune                   | ✅       |             |
|                             |                         |          |             |
| Secrets                     | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Create                  | ✅       |             |
|                             | Update                  | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             |                         |          |             |
| Configs                     | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Create                  | ✅       |             |
|                             | Update                  | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             |                         |          |             |
| Tasks                       | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Get logs                | ✅       |             |
|                             |                         |          |             |
| Plugins                     |                         | ❌       |    TBD      |
|                             |                         |          |             |
| Registries                  | Login                   | ✅       | basic implementation |
|                             |                         |          |             |
| Docker error responses mgmt |                         | 🚧       |             |



✅ : done or _mostly_ done

🚧 : work in progress, partially implemented, might not work

❌ : not implemented/supported at the moment.

Note: various Docker endpoints such as list or prune support *filters*. These are currently not implemented.


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
To add DockerClientSwift to your existing Xcode project, select File -> Swift Packages -> Add Package Dependancy. 
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

<details>
  <summary>Listen for Docker daemon events</summary>
  
  We start by listening for docker events, then we create a container.
  ```swift
  async let events = try await client.events()
  
  let container = try await client.containers.create(
      name: "hello",
      spec: .init(
          config: .init(image: "hello-world:latest"),
          hostConfig: .init()
      )
  )
  
  // We should get an event whose `action` is "create" and whose `type` is "container"
  for try await event in try await events {
      print("\n••• event: \(event)")
  }
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
  <summary>Create a container</summary>
  
  Note: you will also need to start it for the container to actually run.
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
  let container = try await docker.containers.create(name: "test", spec: spec)
  ```
</details>

<details>
  <summary>Update a container</summary>
  
  Let's update the memory limits for an existing container:
  ```swift
  let newMemory = 64 * 1024 * 1024 // 64MB
  let newConfig = ContainerUpdate(memoryLimit: newMemory, memorySwap: newMemory)
  try await client.containers.update("nameOrId", spec: newConfig)
  ```
</details>

<details>
  <summary>Start a container</summary>
  
  ```swift
  try await docker.containers.start("nameOrId")
  ```
</details>

<details>
  <summary>Stop a container</summary>
  
  ```swift
  try await client.containers.stop("nameOrId")
  ```
</details>

<details>
  <summary>Rename a container</summary>
  
  ```swift
  try await client.containers.rename("nameOrId", to: "hahi")
  ```
</details>

<details>
  <summary>Delete a container</summary>
  
  If the container is running, deletion can be forced by passing `force: true` 
  ```swift
  try await docker.containers.remove("nameOrId")
  ```
</details>

<details>
  <summary>Get container logs</summary>
  
  Logs are streamed progressively in an asynchronous way.
  
  Get all logs:
  ```swift
  let container = try await docker.containers.get("nameOrId")
        
  for try await line in try await docker.containers.logs(container: container, timestamps: true) {
      print(line.message + "\n")
  }
  ```
  
  Wait for future log messages:
  ```swift
  let service = try await docker.containers.get("nameOrId")
        
  for try await line in try await docker.containers.logs(service: service, follow: true) {
      print(line.message + "\n")
  }
  ```
  
  Only the last 100 messages:
  ```swift
  let service = try await docker.containers.get("nameOrId")
        
  for try await line in try await docker.containers.logs(service: service, tail: 100) {
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
  <summary>Get an image details</summary>
  
  ```swift
  let image = try await docker.images.get("nameOrId")
  ```
</details>

<details>
  <summary>Pull an image</summary>
  
  Pull an image from a public repository:
  ```swift
  let image = try await docker.images.pull(byIdentifier: "hello-world:latest")
  ```

  Pull an image from a registry that requires authentication:
  ```swift
  var credentials = RegistryAuth(username: "myUsername", password: "....")
  let registryAuth = try await docker.registries.login(credentials: &credentials)
  let image = try await docker.images.pull(byIdentifier: "my-private-image:latest", credentials: registryAuth)
  ```
  > NOTE: `RegistryAuth` also accepts a `serverAddress` parameter in order to use a custom registry.
</details>

<details>
  <summary>Push an image</summary>

  Supposing that the Docker deamon has an image named "my-private-image:latest":
  ```swift
  var credentials = RegistryAuth(username: "myUsername", password: "....")
  let registryAuth = try await docker.registries.login(credentials: &credentials)
  try await docker.images.push("my-private-image:latest", credentials: registryAuth)
  ```
  > NOTE: `RegistryAuth` also accepts a `serverAddress` parameter in order to use a custom registry.
</details>

<details>
  <summary>Build an image</summary>
  
  The current implementation of this library is very bare-bones.
  The Docker build context, containing the Dockerfile and any other resources required during the build, must be passed as a TAR archive.
  
  Supposing we already have a TAR archive of the build context:
  ```swift
  let tar = FileManager.default.contents(atPath: "/tmp/docker-build.tar")
  let buffer = ByteBuffer.init(data: tar)
  let buildOutput = try await docker.images.build(
      config: .init(repoTags: ["build:test"]),
      context: buffer
  )
  var imageId: String? = nil
  for try await item in buildOutput {
      if item.aux != nil {
          imageId = item.aux!.id
          print("\n• Image ID: \(imageId!)")
      }
      else {
        print("\n• Build output: \(item.stream)")
      }
  }
  ```
  
  You can use external libraries to create TAR archives of your build context.
  Example with Tarscape (https://github.com/kayembi/Tarscape):
  ```swift
  import Tarscape
  
  let tarContextPath = "/tmp/docker-build.tar"
  try FileManager.default.createTar(
      at: URL(fileURLWithPath: tarContextPath),
      from: URL(string: "file:///path/to/your/context/folder")!
  )
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
> This requires a Docker daemon with Swarm mode enabled.
> Additionally, the client must be connected to a manager node.

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
  let service = try await docker.services.create(spec: spec)
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
  let service = try await docker.services.create(spec: spec)
  ```
  TODO: add examples for specifying networks and volumes
</details>
        
<details>
  <summary>Get service logs</summary>
  
  Logs are streamed progressively in an asynchronous way.
  
  Get all logs:
  ```swift
  let service = try await docker.services.get("nameOrId")
        
  for try await line in try await docker.services.logs(service: service) {
      print(line.message + "\n")
  }
  ```
  
  Wait for future log messages:
  ```swift
  let service = try await docker.services.get("nameOrId")
        
  for try await line in try await docker.services.logs(service: service, follow: true) {
      print(line.message + "\n")
  }
  ```
  
  Only the last 100 messages:
  ```swift
  let service = try await docker.services.get("nameOrId")
        
  for try await line in try await docker.services.logs(service: service, tail: 100) {
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
<details>
  <summary>List networks</summary>
  
  ```swift
  let networks = try await docker.networks.list()
  ```
</details>

<details>
  <summary>Get a network details</summary>
  
  ```swift
  let network = try await docker.networks.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a network</summary>
  
  ```swift
  let network = try await docker.networks.create(
    spec: .init(name: name)
  )
  ```
</details>

<details>
  <summary>Delete a network</summary>
  
  ```swift
  try await docker.networks.remove("nameOrId")
  ```
</details>

### Volumes
<details>
  <summary>List volumes</summary>
  
  ```swift
  let volumes = try await docker.volumes.list()
  ```
</details>

<details>
  <summary>Get a volume details</summary>
  
  ```swift
  let volume = try await docker.volumes.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a volume</summary>
  
  ```swift
  let volume = try await docker.volumes.create(
    spec: .init(name: "myVolume", labels: ["myLabel": "value"])
  )
  ```
</details>

<details>
  <summary>Delete a volume</summary>
  
  ```swift
  try await docker.volumes.remove("nameOrId")
  ```
</details>


### Secrets
> This requires a Docker daemon with Swarm mode enabled.

The API is very similar for managing Docker Configs and the below examples also apply to them.

<details>
  <summary>List secrets</summary>
  
  ```swift
  let secrets = try await docker.secrets.list()
  ```
</details>

<details>
  <summary>Get a secret details</summary>
  
  Note: The Docker API doesn't return secret data/values.
  ```swift
  let secret = try await docker.secrets.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a secret</summary>
  
  Create a Secret containing a `String` value:
  ```swift
  let secret = try await docker.secrets.create(
    spec: .init(name: "myVolume", data: "test secret value 💥")
  )
  ```
  
  You can also pass a `Data` value to store as a Secret:
  ```swift
  let data: Data = ...
  let secret = try await docker.secrets.create(
    spec: .init(name: "myVolume", data: data)
  )
  ```
</details>

<details>
  <summary>Update a secret</summary>
  
  Currently, only the `labels` field can be updated (Docker limitation).
  ```swift
  try await docker.secrets.update("nameOrId", labels: ["myKey": "myValue"])
  ```
</details>

<details>
  <summary>Delete a secret</summary>
  
  ```swift
  try await docker.secrets.remove("nameOrId")
  ```
</details>


## Credits
This is a fork of the great work at https://github.com/alexsteinerde/docker-client-swift

## License
This project is released under the MIT license. See [LICENSE](LICENSE) for details.


## Contribution
You can contribute to this project by submitting a detailed issue or by forking this project and sending a pull request. Contributions of any kind are very welcome :)
