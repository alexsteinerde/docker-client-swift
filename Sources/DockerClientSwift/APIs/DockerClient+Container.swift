import Foundation
import NIO
import AsyncHTTPClient

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
        /// - Returns: Returns a list of `Container`.
        public func list(all: Bool = false) async throws -> [ContainerSummary] {
            return try await client.run(ListContainersEndpoint(all: all))
        }
        
        /// Fetches the latest information about a container by a given name or id..
        /// - Parameter nameOrId: Name or id of a container.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the `Container` and its information.
        public func get(_ nameOrId: String) async throws -> Container {
            return try await client.run(InspectContainerEndpoint(nameOrId: nameOrId))
        }
        
        /// Creates a new container from a given image. If specified the commands override the default commands from the image.
        /// - Parameters:
        ///   - image: Instance of an `Image`.
        ///   - commands: Override the default commands from the image. Default `nil`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  the created `Container`.
        public func create(image: Image, commands: [String]? = nil) async throws -> Container {
            let response = try await client.run(SimpleCreateContainerEndpoint(imageName: image.id, commands: commands))
            let container = try await get(response.Id)
            return container
        }
        
        /// Creates a new container from a fully customizable config.
        /// - Parameters:
        ///   - name:  Custom name for this container. If not set, a random one will be generated by Docker. Must match `/?[a-zA-Z0-9][a-zA-Z0-9_.-]+` (must start with a letter or number, then must only contain letters, numbers, _, ., -)
        ///   - spec: a `ContainerCreate` representing the container configuration.
        /// - Returns: Returns  the created `Container`.
        public func create(name: String? = nil, spec: ContainerCreate) async throws -> Container {
            let response = try await client.run(CreateContainerEndpoint(name: name, spec: spec))
            let container = try await get(response.Id)
            return container
        }
        
        /// Updates an existing container.
        /// - Parameters:
        ///   - nameOrId: Name or id of a container.
        ///   - spec: a `ContainerUpdate` representing the configuration to update.
        /// - Throws: Errors that can occur when executing the request.
        public func update(_ nameOrId: String, spec: ContainerUpdate) async throws {
            try await client.run(UpdateContainerEndpoint(nameOrId: nameOrId, spec: spec))
        }
        
        /// Starts a container. Before starting it needs to be created.
        /// - Parameter nameOrId: Name or Id of the`Container`.
        /// - Throws: Errors that can occur when executing the request.
        public func start(_ nameOrId: String) async throws {
            try await client.run(StartContainerEndpoint(containerId: nameOrId))
        }
        
        /// Stops a container. Before stopping it needs to be created and started.
        /// - Parameter nameOrId: Name or Id of the`Container`.
        /// - Throws: Errors that can occur when executing the request.
        public func stop(_ nameOrId: String) async throws {
            try await client.run(StopContainerEndpoint(containerId: nameOrId))
        }
        
        /// Pauses a container.
        /// Uses the freezer cgroup to suspend all processes in a container.
        /// Traditionally, when suspending a process the SIGSTOP signal is used, which is observable by the process being suspended.
        /// With the freezer cgroup the process is unaware, and unable to capture, that it is being suspended, and subsequently resumed.
        /// - Parameter nameOrId: Name or Id of the`Container`.
        /// - Throws: Errors that can occur when executing the request.
        public func pause(_ nameOrId: String) async throws {
            try await client.run(PauseUnpauseContainerEndpoint(nameOrId: nameOrId, unpause: false))
        }
        
        /// Resume a container which has been paused.
        /// - Parameter nameOrId: Name or Id of the`Container`.
        /// - Throws: Errors that can occur when executing the request.
        public func unpause(_ nameOrId: String) async throws {
            try await client.run(PauseUnpauseContainerEndpoint(nameOrId: nameOrId, unpause: true))
        }
        
        /// Renames a container.
        /// - Parameters:
        ///   - nameOrId: Name or Id of the`Container`.
        ///   - to: The new name of the `Container`.
        /// - Throws: Errors that can occur when executing the request.
        public func rename(_ nameOrId: String, to newName: String) async throws {
            try await client.run(RenameContainerEndpoint(containerId: nameOrId, newName: newName))
        }
        
        /// Removes an existing container.
        /// - Parameters:
        ///   - nameOrId: Name or Id of the`Container`.
        ///   - force: Delete even if it is running
        ///   - removeAnonymousVolumes: Remove anonymous volumes associated with the container.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(_ nameOrId: String, force: Bool = false, removeAnonymousVolumes: Bool = false) async throws {
            try await client.run(RemoveContainerEndpoint(containerId: nameOrId, force: force, removeAnonymousVolumes: removeAnonymousVolumes))
        }
        
        /// Gets the logs of a container.
        /// - Parameters:
        ///   - container: Instance of an `Container`.
        ///   - stdErr: whether to return log lines from the standard error.
        ///   - stdOut: whether to return log lines from the standard output.
        ///   - timestamps: whether to return the timestamp of each log line
        ///   - follow: whether to wait for new logs to become available and stream them.
        ///   - tail: number of last existing log lines to return. Default: all.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  a  sequence of `DockerLogEntry`.
        public func logs(container: Container, stdErr: Bool = true, stdOut: Bool = true, timestamps: Bool = true, follow: Bool = false, tail: UInt? = nil, since: Date = .distantPast, until: Date = .distantFuture) async throws -> AsyncThrowingStream<DockerLogEntry, Error> {
            let endpoint = GetContainerLogsEndpoint(
                containerId: container.id,
                stdout: stdOut,
                stderr: stdErr,
                timestamps: timestamps,
                follow: follow,
                tail: tail == nil ? "all" : "\(tail!)",
                since: since,
                until: until
            )
            let response = try await client.run(
                endpoint,
                // Arbitrary timeouts.
                // TODO: should probably make these configurable
                timeout: follow ? .hours(12) : .seconds(60)
            )
            
            return try await endpoint.map(response: response, tty: container.config.tty)
        }
        
        /// Deletes all stopped containers.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` with a list of deleted `Container` and the reclaimed space.
        public func prune() async throws -> PrunedContainers {
            let response =  try await client.run(PruneContainersEndpoint())
            return PrunedContainers(
                containersIds: response.ContainersDeleted?.map({ .init($0)}) ?? [],
                reclaimedSpace: response.SpaceReclaimed
            )
        }
        
        public struct PrunedContainers {
            /// IDs of the containers that were deleted.
            let containersIds: [String]
            
            /// Disk space reclaimed in bytes.
            let reclaimedSpace: UInt64
        }
        
        /// Blocks until a container stops, then returns the exit code.
        /// - Parameter nameOrId: Name or Id of the`Container`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the exit code of the`Container` (`0` meaning success/no error).
        public func wait(_ nameOrId: String) async throws -> Int {
            let response = try await client.run(WaitContainerEndpoint(nameOrId: nameOrId))
            return response.StatusCode
        }
        
        /// Returns which files in a container's filesystem have been added, deleted, or modified.
        /// - Parameter nameOrId: Name or Id of the`Container`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a list of `ContainerFsChange`.
        public func getFsChanges(_ nameOrId: String) async throws -> [ContainerFsChange] {
            return try await client.run(GetContainerChangesEndpoint(nameOrId: nameOrId))
        }
        
        /// Returns `ps`-like raw info about processes running in a container
        /// - Parameters:
        ///   - nameOrId: Name or Id of the`Container`.
        ///   - psArgs: options to pass to the `ps` command. Defaults to `-ef`
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a `ContainerTop`instance.
        public func processes(_ nameOrId: String, psArgs: String = "-ef") async throws -> ContainerTop {
            return try await client.run(ContainerTopEndpoint(nameOrId: nameOrId, psArgs: psArgs))
        }
    }
}

