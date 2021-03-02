import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to containers.
    public var containers: ContainersAPI {
        ContainersAPI(client: self)
    }
    
    public struct ContainersAPI {
        fileprivate var client: DockerClient
        
        public func list(all: Bool=false) throws -> EventLoopFuture<[Container]> {
            try client.run(ListContainersEndpoint(all: all))
                .map({ containers in
                    containers.map { container in
                        Container(id: .init(container.Id), image: Image(id: .init(container.Image), digest: nil), createdAt: Date(timeIntervalSince1970: TimeInterval(container.Created)))
                    }
                })
        }
        
        public func createContainer(image: Image, commands: [String]?=nil) throws -> EventLoopFuture<Container> {
            var id = image.id.value
            if let tag = image.repositoryTags.first?.tag {
                id += ":\(tag)"
            }
            if let digest = image.digest {
                id += "@\(digest.rawValue)"
            }
            return try client.run(CreateContainerEndpoint(imageName: id, commands: commands))
                .map({ response in
                    Container(id: .init(response.Id), image: image, createdAt: .init())
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
    }
}

extension Container {
    public func start(on client: DockerClient) throws -> EventLoopFuture<Void> {
        try client.containers.start(container: self)
    }
    
    public func logs(on client: DockerClient) throws -> EventLoopFuture<String> {
        try client.containers.logs(container: self)
    }
}
