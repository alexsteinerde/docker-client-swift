# Docker Client
[![Language](https://img.shields.io/badge/Swift-5.5-brightgreen.svg)](http://swift.org)
[![Docker Engine API](https://img.shields.io/badge/Docker%20Engine%20API-%20%201.41-blue)](https://docs.docker.com/engine/api/v1.41/)
[![Platforms](https://img.shields.io/badge/platform-linux--64%20%7C%20osx--64-blue)]()

This is a low-level, **work in progress** Docker Client written in Swift. It very closely follows the Docker API.

It fully uses the Swift concurrency features introduced with Swift 5.5 (`async`/`await`).


## Docker API version support
This client library aims at implementing the Docker API version 1.41 (https://docs.docker.com/engine/api/v1.41).
This means that it will work with Docker >= 20.10.


## Current implementation status

| Section                     | Operation               | Support  | Notes       |
|-----------------------------|-------------------------|----------|-------------|
| Client connection           | Local Unix socket       | ✅       |             |
|                             | HTTP                    | ✅       |             |
|                             | HTTPS                   | ✅       |             |
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
|                             | Get stats               | ✅       |             |
|                             | Get processes (top)     | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             | Prune                   | ✅       |             |
|                             | Wait                    | ✅       | untested    |
|                             | Filesystem changes      | ✅       | untested    |
|                             | Attach                  | ✅       | basic support <sup>1</sup>|
|                             | Exec                    | ❌       | unlikely <sup>2</sup>|
|                             |                         |          |             |
| Images                      | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | History                 | ✅       |             |
|                             | Pull                    | ✅       | basic support |
|                             | Build                   | ✅       | basic support |
|                             | Tag                     | ✅       |             |
|                             | Push                    | ✅       |             |
|                             | Create (container commit)| ❌       | TBD         |
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
|                             | Update                  | ✅       |             |
|                             | Rollback                | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             |                         |          |             |
| Networks                    | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Create                  | ✅       |             |
|                             | Delete                  | ✅       |             |
|                             | Prune                   | ✅       |             |
|                             | (Dis)connect container  | 🚧       | WIP <sup>3</sup>|
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
| Plugins                     | List                    | ✅       |             |
|                             | Inspect                 | ✅       |             |
|                             | Get Privileges          | ✅       |             |
|                             | Install                 | ✅       |             |
|                             | Remove                  | ✅       |             |
|                             | Enable/disable          | ✅       |             |
|                             | Upgrade                 | ✅       | untested    |
|                             | Configure               | ✅       | untested    |
|                             | Create                  | ❌       | TBD         |
|                             | Push                    | ❌       | TBD         |
|                             |                         |          |             |
| Registries                  | Login                   | ✅       | basic support |
|                             |                         |          |             |
| Docker error responses mgmt |                         | 🚧       |             |



✅ : done or _mostly_ done

🚧 : work in progress, partially implemented, might not work

❌ : not implemented/supported at the moment.

Note: various Docker endpoints such as list or prune support *filters*. These are currently not implemented.

<sup>1</sup> Attach is currently **not** supported when connecting to Docker via local Unix socket, or when using a proxy.

<sup>2</sup> Docker exec is using an unconventional protocol that requires raw access to the TCP socket. Significant work needed in order to support it.

<sup>3</sup> Only Disconnect is currently implemented.


## Installation
### Package.swift 
```Swift
import PackageDescription

let package = Package(
    dependencies: [
        .package(url: "https://github.com/m-barthelemy/docker-client-swift.git", .branch("main")),
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
Enter `https://github.com/m-barthelemy/docker-client-swift.git` for the URL.


## Usage Examples

### Connect to a Docker deamon

Local socket (defaults to `/var/run/docker.sock`):
```swift
let docker = DockerClient()
```

Remote daemon over HTTP:
```swift
let docker = DockerClient(deamonURL: .init(string: "http://127.0.0.1:2375")!)
```

Remote daemon over HTTPS, using a client certificate for authentication:
```swift
var tlsConfig = TLSConfiguration.makeClientConfiguration()
tlsConfig.privateKey = NIOSSLPrivateKeySource.file("client-key.pem")
tlsConfig.certificateChain.append(NIOSSLCertificateSource.file("client-certificate.pem"))
tlsConfig.additionalTrustRoots.append(.file("docker-daemon-ca.pem"))
tlsConfig.certificateVerification = .noHostnameVerification

let docker = DockerClient(
    deamonURL: .init(string: "https://your.docker.daemon:2376")!,
    tlsConfig: tlsConfig
)
```

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
  
  We start by listening for docker events, then we create a container:
  ```swift
  async let events = try await docker.events()
  
  let container = try await docker.containers.create(
      name: "hello",
      spec: .init(
          config: .init(image: "hello-world:latest"),
          hostConfig: .init()
      )
  )
  ```
  
  Now, we should get an event whose `action` is "create" and whose `type` is "container".
  ```swift
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
  
  > Note: you will also need to start it for the container to actually run.
  
  The simplest way of creating a new container is to only specify the image to run:
  ```swift
  let spec = ContainerSpec(
      config: .init(image: "hello-world:latest")
  )
  let container = try await docker.containers.create(name: "test", spec: spec)
  ```
  
  Docker allows customizing many parameters:
  ```swift
  let memory: UInt64 = 64 * 1024 * 1024
  let spec = ContainerSpec(
      config: .init(
          // Override the default command of the Image
          command: ["/custom/command", "--option"],
          // Add new environment variables
          environmentVars: ["HELLO=hi"],
          // Expose port 80
          exposedPorts: [.tcp(80)],
          image: "nginx:latest",
          // Set custon container labels
          labels: ["label1": "value1", "label2": "value2"]
      ),
      hostConfig: .init(
          // Maximum memory the container can use
          memoryLimit: memory,
          // Memory the container is allocated when starting
          memoryReservation: memory/2,
          // Needs to be either disabled (-1) or be equal to, or greater than, `memoryLimit`
          memorySwap: Int64(memory),
          // Let's publish the port we exposed in `config`
          portBindings: [.tcp(80): [.publishTo(hostIp: "0.0.0.0", hostPort: 8000)]]
      )
  )
  let container = try await docker.containers.create(name: "nginx-test", spec: spec)
  ```
</details>

<details>
  <summary>Update a container</summary>
  
  Let's update the memory limits for an existing container:
  ```swift
  let newMemory = 64 * 1024 * 1024 // 64MB
  let newConfig = ContainerUpdate(memoryLimit: newMemory, memorySwap: newMemory)
  try await docker.containers.update("nameOrId", spec: newConfig)
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
  try await docker.containers.stop("nameOrId")
  ```
</details>

<details>
  <summary>Rename a container</summary>
  
  ```swift
  try await docker.containers.rename("nameOrId", to: "hahi")
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
  
  > Logs are streamed progressively in an asynchronous way.
  
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

<details>
  <summary>Attach to a container</summary>
  
  Let's create a container that defaults to running a shell, and attach to it:
  ```swift
  let _ = try await docker.images.pull(byIdentifier: "alpine:latest")
  let spec = ContainerSpec(
      config: .init(
          attachStdin: true,
          attachStdout: true,
          attachStderr: true,
          image: "alpine:latest",
          openStdin: true
      )
  )
  let container = try await docker.containers.create(spec: spec)
  let attach = try await docker.containers.attach(container: container, stream: true, logs: true)
  
  // Let's display any output from the container
  Task {
      for try await output in attach.output {
          print("• \(output)")
      }
  }
  
  // We need to be sure that the container is really running before being able to send commands to it.
  try await docker.containers.start(container.id)
  try await Task.sleep(nanoseconds: 1_000_000_000)
  
  // Now let's send the command; the response will be printed to the screen.
  try await attach.send("uname")
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
  
  > Creating images from a remote URL or from the standard input is currently not supported.
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
  
  > The current implementation of this library is very bare-bones.
  > The Docker build context, containing the Dockerfile and any other resources required during the build, must be passed as a TAR archive.
  
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
  Example with [Tarscape](https://github.com/kayembi/Tarscape) (only available on macOS):
  ```swift
  import Tarscape
  
  let tarContextPath = "/tmp/docker-build.tar"
  try FileManager.default.createTar(
      at: URL(fileURLWithPath: tarContextPath),
      from: URL(string: "file:///path/to/your/context/folder")!
  )
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
  
  Create a new network without any custom options:
  ```swift
  let network = try await docker.networks.create(
    spec: .init(name: "my-network")
  )
  ```
  
  Create a new network with custom IPs range:
  ```swift
  let network = try await docker.networks.create(
      spec: .init(
          name: "my-network",
          ipam: .init(
              config: [.init(subnet: "192.168.2.0/24", gateway: "192.168.2.1")]
          )
      )
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


### Swarm
<details>
  <summary>Initialize Swarm mode</summary>
  
  ```swift
  let swarmId = try await docker.swarm.initSwarm()
  ```
</details>

<details>
  <summary>Get Swarm cluster details (inspect)</summary>
  
  > The client must be connected to a Swarm manager node.
  ```swift
  let swarm = try await docker.swarm.get()
  ```
</details>

<details>
  <summary>Make the Docker deamon to join an existing Swarm cluster</summary>
  
  ```swift
  // This first client points to an existing Swarm cluster manager
  let swarmClient = Dockerclient(...)
  let swarm = try await swarmClient.swarm.get()
  
  // This client is the docker daemon we want to add to the Swarm cluster
  let client = Dockerclient(...)
  try await client.swarm.join(
      config: .init(
          // To join the Swarm cluster as a Manager node
          joinToken: swarmClient.joinTokens.manager,
          // IP/Host of the existing Swarm managers
          remoteAddrs: ["10.0.0.1"]
      )
  )
  ```
</details>

<details>
  <summary>Remove the current Node from the Swarm</summary>
  
  > Note: `force` is needed if the node is a manager
  ```swift
  try await docker.swarm.leave(force: true)
  ```
</details>


### Nodes
> This requires a Docker daemon with Swarm mode enabled.
> Additionally, the client must be connected to a manager node.

<details>
  <summary>List the Swarm nodes</summary>
  
  ```swift
  let nodes = try await docker.nodes.list()
  ```
</details>

<details>
  <summary>Remove a Node from a Swarm</summary>
  
  > Note: `force` is needed if the node is a manager
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
  
  Simplest possible example, we only specify the name of the service and the image to use:
  ```swift
  let spec = ServiceSpec(
      name: "my-nginx",
      taskTemplate: .init(
          containerSpec: .init(image: "nginx:latest")
      )
  )
  let service = try await docker.services.create(spec: spec)
  ```
  
  Let's specify a number of replicas, a published port and a memory limit of 64MB for our service:
  ```swift
  let spec = ServiceSpec(
      name: "my-nginx",
      taskTemplate: .init(
          containerSpec: .init(image: "nginx:latest"),
          resources: .init(
              limits: .init(memoryBytes: UInt64(64 * 1024 * 1024))
          ),
          // Uses default Docker routing mesh mode
          endpointSpec: .init(ports: [.init(name: "HTTP", targetPort: 80, publishedPort: 8000)])
      ),
      mode: .replicated(2)
  )
  let service = try await docker.services.create(spec: spec)
  ```
  
  What if we then want to know when our service is fully running?
  ```swift
  var index = 0 // Keep track of how long we've been waiting
  repeat {
      try await Task.sleep(nanoseconds: 1_000_000_000)
      print("\n Service still not fully running!")
      index += 1
  } while try await docker.tasks.list()
        .filter({$0.serviceId == service.id && $0.status.state == .running})
        .count < 1 /* number of replicas */ && index < 15
  print("\n Service is fully running!")
  ```
  
  What if we want to create a one-off job instead of a service?
  ```swift
  let spec = ServiceSpec(
      name: "hello-world-job",
      taskTemplate: .init(
          containerSpec: .init(image: "hello-world:latest"),
          ...
      ),
      mode: .job(1)
  )
  let job = try await docker.services.create(spec: spec)
  ```
  
  Let's create an advanced Service:
  - connected to a custom Network
  - storing data into a custom Volume, for each container
  - requiring a Secret
  ```swift
  let network = try await client.networks.create(spec: .init(name: "myNet", driver: "overlay"))
  let volume = try await client.volumes.create(spec: .init(name: name)
  let secret = try await client.secrets.create(spec: .init(name: "myPassword", value: "blublublu"))
  let spec = ServiceSpec(
      name: "my-nginx",
      taskTemplate: .init(
          containerSpec: .init(
              image: "nginx:latest",
              // Create and mount a dedicated Volume named "myStorage" on each running container. 
              mounts: [.init(type: .volume, source: "myStorage", target: "/mount")],
              // Add our Secret. Will appear as `/run/secrets/myPassword` in the containers.
              secrets: [.init(secret)]
          ),
          resources: .init(
              limits: .init(memoryBytes: UInt64(64 * 1024 * 1024))
          )
      ),
      mode: .replicated(1),
      // Add our custom Network
      networks: [.init(target: network.id)],
      // Publish our Nginx image port 80 to 8000 on the Docker Swarm nodes
      endpointSpec: .init(ports: [.init(name: "HTTP", targetPort: 80, publishedPort: 8000)])
  )
    
  let service = try await client.services.create(spec: spec)
  ```
</details>
 
<details>
  <summary>Update a service</summary>
  
  Let's scale an existing service up to 3 replicas:
  ```swift
  let service = try await docker.services.get("nameOrId")
  var updatedSpec = service.spec
  updatedSpec.mode = .replicated(3)
  try await docker.services.update(service: service, version: service.version.index, spec: updatedSpec)
  ```
</details>
       
<details>
  <summary>Get service logs</summary>
  
  > Logs are streamed progressively in an asynchronous way.
  
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


### Secrets
> This requires a Docker daemon with Swarm mode enabled.
> 
> Note: The API for managing Docker Configs is very similar to the Secrets API and the below examples also apply to them.

<details>
  <summary>List secrets</summary>
  
  ```swift
  let secrets = try await docker.secrets.list()
  ```
</details>

<details>
  <summary>Get a secret details</summary>
  
  > Note: The Docker API doesn't return secret data/values.
  
  ```swift
  let secret = try await docker.secrets.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a secret</summary>
  
  Create a Secret containing a `String` value:
  ```swift
  let secret = try await docker.secrets.create(
    spec: .init(name: "mySecret", value: "test secret value 💥")
  )
  ```
  
  You can also pass a `Data` value to be stored as a Secret:
  ```swift
  let data: Data = ...
  let secret = try await docker.secrets.create(
    spec: .init(name: "mySecret", data: data)
  )
  ```
</details>

<details>
  <summary>Update a secret</summary>
  
  > Currently, only the `labels` field can be updated (Docker limitation).
  
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


### Plugins
<details>
  <summary>List installed plugins</summary>
  
  ```swift
  let plugins = try await docker.plugins.list()
  ```
</details>

<details>
  <summary>Install a plugin</summary>
  
  > Note: the `install()` method can be passed a `credentials` parameter containing credentials for a private registry.
  > See "Pull an image" for more information.
  ```swift
  // First, we fetch the privileges required by the plugin:
  let privileges = try await docker.plugins.getPrivileges("vieux/sshfs:latest")
  
  // Now, we can install it
  try await docker.plugins.install(remote: "vieux/sshfs:latest", privileges: privileges)
  
  // finally, we need to enable it before using it
  try await docker.plugins.enable("vieux/sshfs:latest")
  ```
</details>

## Credits
This is a fork of the great work at https://github.com/alexsteinerde/docker-client-swift

## License
This project is released under the MIT license. See [LICENSE](LICENSE) for details.


## Contribute
You can contribute to this project by submitting a detailed issue or by forking this project and sending a pull request. Contributions of any kind are very welcome :)
