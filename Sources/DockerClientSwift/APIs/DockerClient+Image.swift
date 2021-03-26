import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to images.
    public var images: ImagesAPI {
        .init(client: self)
    }
    
    public struct ImagesAPI {
        fileprivate var client: DockerClient
        
        public func pullImage(byName name: String, tag: String?=nil, digest: Digest?=nil) throws -> EventLoopFuture<Image> {
            var identifier = name
            if let tag = tag {
                identifier += ":\(tag)"
            }
            if let digest = digest {
                identifier += "@\(digest.rawValue)"
            }
            return try pullImage(byIdentifier: identifier)
        }
        
        public func pullImage(byIdentifier identifier: String) throws -> EventLoopFuture<Image> {
            return try client.run(PullImageEndpoint(imageName: identifier))
                .flatMap({ _ in
                    try self.get(imageByNameOrId: identifier)
                })
        }
        
        public func list(all: Bool=false) throws -> EventLoopFuture<[Image]> {
            try client.run(ListImagesEndpoint(all: all))
                .map({ images in
                    images.map { image in
                        Image(id: .init(image.Id), digest: image.RepoDigests?.first.map({ Digest.init($0) }), repoTags: image.RepoTags, createdAt: Date(timeIntervalSince1970: TimeInterval(image.Created)))
                    }
                })
        }
        
        public func remove(image: Image, force: Bool=false) throws -> EventLoopFuture<Void> {
            try client.run(RemoveImageEndpoint(imageId: image.id.value, force: force))
                .map({ _ in Void() })
        }
        
        public func get(imageByNameOrId nameOrId: String) throws -> EventLoopFuture<Image> {
            try client.run(InspectImagesEndpoint(nameOrId: nameOrId))
                .map { image in
                    Image(id: .init(image.Id), digest: image.RepoDigests?.first.map({ Digest.init($0) }), repoTags: image.RepoTags, createdAt: Date.parseDockerDate(image.Created)!)
                }
        }
        
        
        /// Delete unused images
        public func prune(all: Bool=false) throws -> EventLoopFuture<PrunedImages> {
            return try client.run(PruneImagesEndpoint(dangling: !all))
                .map({ response in
                    return PrunedImages(imageIds: response.ImagesDeleted?.compactMap(\.Deleted).map({ .init($0)}) ?? [], reclaimedSpace: response.SpaceReclaimed)
                })
        }
        
        public struct PrunedImages {
            let imageIds: [Identifier<Image>]
            
            /// Disk space reclaimed in bytes
            let reclaimedSpace: Int
        }
    }
}

extension Image {
    public func remove(on client: DockerClient, force: Bool=false) throws -> EventLoopFuture<Void> {
        try client.images.remove(image: self, force: force)
    }
}

extension Image {
    static func parseNameTagDigest(_ value: String) -> (Digest, RepositoryTag)? {
        let components = value.split(separator: "@").map(String.init)
        if components.count == 2, let nameTag = RepositoryTag(components[0]) {
            return (.init(components[1]), nameTag)
        } else {
            return nil
        }
    }
}
