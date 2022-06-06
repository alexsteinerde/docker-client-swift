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
        public func list(all: Bool=false) async throws -> [Container] {
            try await client.run(ListContainersEndpoint(all: all))
                .map({ container in
                    var digest: Digest?
                    var repositoryTag: Image.RepositoryTag?
                    if let value =  Image.parseNameTagDigest(container.Image) {
                        (digest, repositoryTag) = value
                    } else if let repoTag = Image.RepositoryTag(container.Image) {
                        repositoryTag = repoTag
                    }
                    let image = Image(id: .init(container.ImageID), digest: digest, repositoryTags: repositoryTag.map({ [$0]}), createdAt: nil)
                    return Container(id: .init(container.Id), image: image, createdAt: Date(timeIntervalSince1970: TimeInterval(container.Created)), names: container.Names, state: container.State, command: container.Command)
                })
        }
        
        /// Creates a new container from a given image. If specified the commands override the default commands from the image.
        /// - Parameters:
        ///   - image: Instance of an `Image`.
        ///   - commands: Override the default commands from the image. Default `nil`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  a `Container`.
        public func createContainer(image: Image, commands: [String]?=nil) async throws -> Container {
            let response = try await client.run(CreateContainerEndpoint(imageName: image.id.value, commands: commands))
            return try await self.get(response.Id)
        }
        
        /// Starts a container. Before starting it needs to be created.
        /// - Parameter container: Instance of a created `Container`.
        /// - Throws: Errors that can occur when executing the request.
        public func start(container: Container) async throws {
            try await client.run(StartContainerEndpoint(containerId: container.id.value))
        }
        
        /// Stops a container. Before stopping it needs to be created and started..
        /// - Parameter container: Instance of a started `Container`.
        /// - Throws: Errors that can occur when executing the request.
        public func stop(container: Container) async throws {
            try await client.run(StopContainerEndpoint(containerId: container.id.value))
        }
        
        /// Removes an existing container.
        /// - Parameter container: Instance of an existing `Container`.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(container: Container) async throws {
            try await client.run(RemoveContainerEndpoint(containerId: container.id.value))
        }
        
        /// Gets the logs of a container as plain text. This function does not return future log statements but only the once that happen until now.
        /// - Parameter container: Instance of a `Container` you want to get the logs for.
        /// - Throws: Errors that can occur when executing the request.
        /*public func logs(container: Container) async throws -> String {
            let response = try await client.run(GetContainerLogsEndpoint(containerId: container.id.value))
            // Removing the first character of each line because random characters went there.
            // TODO: first char is the stream (stdout/stderr). Return structured messages instead of a string
            return response.split(separator: "\n")
                .map({ originalLine in
                    var line = originalLine
                    line.removeFirst(8)
                    return String(line)
                })
                .joined(separator: "\n")
        }*/
        
        public enum DockerLogEntrysource: String, Codable {
            case stdout, stderr
        }
        public struct LogEntry: Codable {
            public let source: DockerLogEntrysource
            public let timestamp: Date
            public let message: String
            public var eof: Bool = false
        }
        
        /*struct LogEntrySequence: AsyncSequence, AsyncIteratorProtocol {
            typealias Element = LogEntry
            private var stream: HTTPClientResponse.Body
            private var iterator: AsyncIterator
            internal init(stream: HTTPClientResponse.Body ) {
                self.stream = stream
                self.iterator = stream.makeAsyncIterator()
            }
            
            
            mutating func next() async -> Element? {
                
                return iterator.next()
            }
            
            func makeAsyncIterator() -> LogEntrySequence {
                self
            }
        }*/

        enum DockerLogDecodingError: Error {
            case dataCorrupted
            case timestampCorrupted
            case noTimestampFound
            case noMessageFound
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
        /// - Returns: Returns  a  sequence of `LogEntry`.
        public func logs(container: Container, stdErr: Bool = true, stdOut: Bool = true, timestamps: Bool = true, follow: Bool = false, tail: UInt? = nil) async throws -> AsyncThrowingStream<LogEntry, Error> {
            let response = try await client.run(
                GetContainerLogsEndpoint(
                    containerId: container.id.value,
                    stdout: stdOut,
                    stderr: stdErr,
                    timestamps: timestamps,
                    follow: follow,
                    tail: tail == nil ? "all" : "\(tail!)"
                ),
                timeout: follow ? .hours(24) : .seconds(30)
            )
            
            let format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
            let timestampLen = 31 //format.count
            let formatter = DateFormatter()
            formatter.dateFormat = format
            
            return AsyncThrowingStream<LogEntry, Error> { continuation in
                Task {
                    for try await buffer in try await response {
                        let data = Data(buffer: buffer)
                        for line in data.split(separator: 10 /*\n*/) {
                            let slice = line.dropFirst(8)
                            let message = Data(slice)
                            guard let string = String(data: message, encoding: .utf8) else {
                                continuation.finish(throwing: DockerLogDecodingError.dataCorrupted)
                                return
                            }
                            print("\n•••rawLine='\(string)'")
                            //let splat = string.split(separator: " ")
                            
                            let timestampRaw = string.prefix(timestampLen - 1) /*else {
                                continuation.finish(throwing: DockerLogDecodingError.noTimestampFound)
                                return
                            }*/
                            print("\n•••timestampRaw='\(timestampRaw)'")
                            guard let timestamp = formatter.date(from: String(timestampRaw)) else {
                                continuation.finish(throwing: DockerLogDecodingError.timestampCorrupted)
                                return
                            }
                            let logMessage = String(string.suffix(string.count - timestampLen))
                            
                            continuation.yield(LogEntry(source: .stdout, timestamp: timestamp, message: logMessage))
                        }
                    }
                    continuation.finish()
                }
            }
        }
        
        /// Fetches the latest information about a container by a given name or id..
        /// - Parameter nameOrId: Name or id of a container.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the `Container` and its information.
        public func get(_ nameOrId: String) async throws -> Container {
            let response = try await client.run(InspectContainerEndpoint(nameOrId: nameOrId))
            var digest: Digest?
            var repositoryTag: Image.RepositoryTag?
            if let value =  Image.parseNameTagDigest(response.Image) {
                (digest, repositoryTag) = value
            } else if let repoTag = Image.RepositoryTag(response.Image) {
                repositoryTag = repoTag
            }
            let image = Image(id: .init(response.Image), digest: digest, repositoryTags: repositoryTag.map({ [$0]}), createdAt: nil)
            return Container(
                id: .init(response.Id),
                image: image,
                createdAt: response.Created,
                names: [response.Name],
                state: response.State.Status,
                command: response.Config.Cmd.joined(separator: " ")
            )
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
    public func start(on client: DockerClient) async throws {
        try await client.containers.start(container: self)
    }
    
    /// Stops a container.
    /// - Parameter client: A `DockerClient` instance that is used to perform the request.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns an `EventLoopFuture` when the container is stopped.
    public func stop(on client: DockerClient) async throws {
        try await client.containers.stop(container: self)
    }
    
    /// Removes a container
    /// - Parameter client: A `DockerClient` instance that is used to perform the request.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns an `EventLoopFuture` when the container is removed.
    public func remove(on client: DockerClient) async throws {
        try await client.containers.remove(container: self)
    }
    
    /// Gets the logs of a container as plain text. This function does not return future log statements but only the once that happen until now.
    /// - Parameter client: A `DockerClient` instance that is used to perform the request.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Return an `EventLoopFuture` with the logs as a plain text `String`.
    /*public func logs(on client: DockerClient) async throws -> String {
        return try await client.containers.logs(container: self)
    }*/
}
