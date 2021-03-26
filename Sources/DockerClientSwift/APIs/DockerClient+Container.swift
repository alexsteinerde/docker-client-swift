import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to containers.
    public var containers: ContainersAPI {
        .init(client: self)
    }
    
    public struct ContainersAPI {
        fileprivate var client: DockerClient
        
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
        
        public func createContainer(image: Image, commands: [String]?=nil) throws -> EventLoopFuture<Container> {
            return try client.run(CreateContainerEndpoint(imageName: image.id.value, commands: commands))
                .flatMap({ response in
                    try self.get(containerByNameOrId: response.Id)
                })
        }
        
        public func start(container: Container) throws -> EventLoopFuture<Void> {
            return try client.run(StartContainerEndpoint(containerId: container.id.value))
                .map({ _ in Void() })
        }
        
        public func logs(container: Container) throws -> EventLoopFuture<String> {
            try client.run(GetContainerLogsEndpoint(containerId: container.id.value))
                .map({ response in
                    // Removing the first character of each line because random characters went there
                    response.split(separator: "\n")
                        .map({ originalLine in
                            var line = originalLine
                            line.removeFirst(8)
                            return String(line)
                        })
                        .joined(separator: "\n")
                })
        }
        
        public func remove(container: Container) throws -> EventLoopFuture<Void> {
            return try client.run(RemoveContainerEndpoint(containerId: container.id.value))
                .map({ _ in Void() })
        }
        
        public func stop(container: Container) throws -> EventLoopFuture<Void> {
            return try client.run(StopContainerEndpoint(containerId: container.id.value))
                .map({ _ in Void() })
        }
        
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
                    return Container(id: .init(response.Id), image: image, createdAt: Date.parseDockerDate(response.Created)!, names: [response.Name], state: response.State.Status, command: response.Config.Cmd.joined(separator: " "))
                }
        }
        
        /// Delete stopped containers
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
    public func start(on client: DockerClient) throws -> EventLoopFuture<Void> {
        try client.containers.start(container: self)
    }
   
    public func stop(on client: DockerClient) throws -> EventLoopFuture<Void> {
        try client.containers.stop(container: self)
    }
    
    public func remove(on client: DockerClient) throws -> EventLoopFuture<Void> {
        try client.containers.remove(container: self)
    }
    
    public func logs(on client: DockerClient) throws -> EventLoopFuture<String> {
        try client.containers.logs(container: self)
    }
}
