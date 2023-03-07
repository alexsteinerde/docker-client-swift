import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to containers.
    public var containers: ContainersAPI {
        .init(client: self)
    }
    
    public struct ContainersAPI {
        fileprivate var client: DockerClient
        
        /// Fetches all containers in the Docker system.
        /// - Parameter all: If `true` all containers are fetched, otherwise only running containers.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` with a list of `Container`.
        public func list(all: Bool=false) throws -> EventLoopFuture<[Container]> {
            try client.run(ListContainersEndpoint(all: all))
                .map({ containers in
                    containers.map { container in
                        var digest: Digest?
                        var repositoryTag: Image.RepositoryTag?
                        if let value =  Image.parseNameTagDigest(container.Image) {
                            (digest, repositoryTag) = value
                        } else if let repoTag = Image.RepositoryTag(container.Image) {
                            repositoryTag = repoTag
                        }
                        let image = Image(id: .init(container.ImageID), digest: digest, repositoryTags: repositoryTag.map({ [$0]}), createdAt: nil)
                        return Container(id: .init(container.Id), image: image, createdAt: Date(timeIntervalSince1970: TimeInterval(container.Created)), names: container.Names, state: container.State, command: container.Command)
                    }
                })
        }
        
        /// Creates a new container from a given image. If specified the commands override the default commands from the image.
        /// - Parameters:
        ///   - image: Instance of an `Image`.
        ///   - commands: Override the default commands from the image. Default `nil`.
        ///   - portBindings: Port bindings (forwardings). See ``PortBinding`` for details. Default `[]`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` of a `Container`.
        public func createContainer(image: Image, commands: [String]?=nil, portBindings: [PortBinding]=[]) throws -> EventLoopFuture<Container> {
            let hostConfig: CreateContainerEndpoint.CreateContainerBody.HostConfig?
            let exposedPorts: [String: CreateContainerEndpoint.CreateContainerBody.Empty]?
            if portBindings.isEmpty {
                exposedPorts = nil
                hostConfig = nil
            } else {
                var exposedPortsBuilder: [String: CreateContainerEndpoint.CreateContainerBody.Empty] = [:]
                var portBindingsByContainerPort: [String: [CreateContainerEndpoint.CreateContainerBody.HostConfig.PortBinding]] = [:]
                for portBinding in portBindings {
                    let containerPort: String = "\(portBinding.containerPort)/\(portBinding.networkProtocol)"
                    
                    exposedPortsBuilder[containerPort] = CreateContainerEndpoint.CreateContainerBody.Empty()
                    var hostAddresses = portBindingsByContainerPort[containerPort, default: []]
                    hostAddresses.append(
                        CreateContainerEndpoint.CreateContainerBody.HostConfig.PortBinding(HostIp: "\(portBinding.hostIP)", HostPort: "\(portBinding.hostPort)"))
                    portBindingsByContainerPort[containerPort] = hostAddresses
                }
                exposedPorts = exposedPortsBuilder
                hostConfig = CreateContainerEndpoint.CreateContainerBody.HostConfig(PortBindings: portBindingsByContainerPort)
            }
            return try client.run(CreateContainerEndpoint(imageName: image.id.value, commands: commands, exposedPorts: exposedPorts, hostConfig: hostConfig))
                .flatMap({ response in
                    try self.get(containerByNameOrId: response.Id)
                })
        }
        
        /// Starts a container. Before starting it needs to be created.
        /// - Parameter container: Instance of a created `Container`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` of active actual `PortBinding`s when the container is started.
        public func start(container: Container) throws -> EventLoopFuture<[PortBinding]> {
            return try client.run(StartContainerEndpoint(containerId: container.id.value))
                .flatMap { _ in
                    try client.run(InspectContainerEndpoint(nameOrId: container.id.value))
                        .flatMapThrowing { response in
                            try response.NetworkSettings.Ports.flatMap { (containerPortSpec, bindings) in
                                let containerPortParts = containerPortSpec.split(separator: "/", maxSplits: 2)
                                guard
                                    let containerPort: UInt16 = UInt16(containerPortParts[0]),
                                    let networkProtocol: NetworkProtocol = NetworkProtocol(rawValue: String(containerPortParts[1]))
                                else { throw DockerError.message(#"unable to parse port/protocol from NetworkSettings.Ports key - "\#(containerPortSpec)""#) }
                                
                                return try (bindings ?? []).compactMap { binding in
                                    guard
                                        let hostPort = UInt16(binding.HostPort)
                                    else {
                                        throw DockerError.message(#"unable to parse port number from NetworkSettings.Ports[].HostPort - "\#(binding.HostPort)""#)
                                    }

                                    return PortBinding(hostIP: binding.HostIp, hostPort: hostPort, containerPort: containerPort, networkProtocol: networkProtocol)
                                }
                            }
                        }
                }
        }
        
        /// Stops a container. Before stopping it needs to be created and started..
        /// - Parameter container: Instance of a started `Container`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` when the container is stopped.
        public func stop(container: Container) throws -> EventLoopFuture<Void> {
            return try client.run(StopContainerEndpoint(containerId: container.id.value))
                .map({ _ in Void() })
        }
        
        /// Removes an existing container.
        /// - Parameter container: Instance of an existing `Container`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` when the container is removed.
        public func remove(container: Container) throws -> EventLoopFuture<Void> {
            return try client.run(RemoveContainerEndpoint(containerId: container.id.value))
                .map({ _ in Void() })
        }
        
        /// Gets the logs of a container as plain text. This function does not return future log statements but only the once that happen until now.
        /// - Parameter container: Instance of a `Container` you want to get the logs for.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return an `EventLoopFuture` with the logs as a plain text `String`.
        public func logs(container: Container) throws -> EventLoopFuture<String> {
            try client.run(GetContainerLogsEndpoint(containerId: container.id.value))
                .map({ response in
                    // Removing the first character of each line because random characters went there.
                    response.split(separator: "\n")
                        .map({ originalLine in
                            var line = originalLine
                            line.removeFirst(8)
                            return String(line)
                        })
                        .joined(separator: "\n")
                })
        }
        
        /// Fetches the latest information about a container by a given name or id..
        /// - Parameter nameOrId: Name or id of a container.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` with the `Container` and its information.
        public func get(containerByNameOrId nameOrId: String) throws -> EventLoopFuture<Container> {
            try client.run(InspectContainerEndpoint(nameOrId: nameOrId))
                .map { response in
                    var digest: Digest?
                    var repositoryTag: Image.RepositoryTag?
                    if let value =  Image.parseNameTagDigest(response.Image) {
                        (digest, repositoryTag) = value
                    } else if let repoTag = Image.RepositoryTag(response.Image) {
                        repositoryTag = repoTag
                    }
                    let image = Image(id: .init(response.Image), digest: digest, repositoryTags: repositoryTag.map({ [$0]}), createdAt: nil)
                    return Container(id: .init(response.Id), image: image, createdAt: Date.parseDockerDate(response.Created)!, names: [response.Name], state: response.State.Status, command: (response.Config.Cmd ?? []).joined(separator: " "))
                }
        }
        
        
        /// Deletes all stopped containers.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` with a list of deleted `Container` and the reclaimed space.
        public func prune() throws -> EventLoopFuture<PrunedContainers> {
            return try client.run(PruneContainersEndpoint())
                .map({ response in
                    return PrunedContainers(containersIds: response.ContainersDeleted?.map({ .init($0)}) ?? [], reclaimedSpace: response.SpaceReclaimed)
                })
        }
        
        public struct PrunedContainers {
            let containersIds: [Identifier<Container>]
            
            /// Disk space reclaimed in bytes
            let reclaimedSpace: Int
        }
    }
}

extension Container {
    /// Starts a container.
    /// - Parameter client: A `DockerClient` instance that is used to perform the request.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns an `EventLoopFuture` when the container is started.
    public func start(on client: DockerClient) throws -> EventLoopFuture<[PortBinding]> {
        try client.containers.start(container: self)
    }
    
    /// Stops a container.
    /// - Parameter client: A `DockerClient` instance that is used to perform the request.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns an `EventLoopFuture` when the container is stopped.
    public func stop(on client: DockerClient) throws -> EventLoopFuture<Void> {
        try client.containers.stop(container: self)
    }
    
    /// Removes a container
    /// - Parameter client: A `DockerClient` instance that is used to perform the request.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns an `EventLoopFuture` when the container is removed.
    public func remove(on client: DockerClient) throws -> EventLoopFuture<Void> {
        try client.containers.remove(container: self)
    }
    
    /// Gets the logs of a container as plain text. This function does not return future log statements but only the once that happen until now.
    /// - Parameter client: A `DockerClient` instance that is used to perform the request.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Return an `EventLoopFuture` with the logs as a plain text `String`.
    public func logs(on client: DockerClient) throws -> EventLoopFuture<String> {
        try client.containers.logs(container: self)
    }
}
