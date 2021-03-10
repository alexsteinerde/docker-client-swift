import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to images.
    public var images: ImagesAPI {
        ImagesAPI(client: self)
    }
    
    public struct ImagesAPI {
        fileprivate var client: DockerClient
        
        public func pullImage(byName name: Identifier<Image>, tag: String?=nil, digest: Digest?=nil) throws -> EventLoopFuture<Image> {
            var identifier = name.value
            if let tag = tag {
                identifier += ":\(tag)"
            }
            if let digest = digest {
                identifier += "@\(digest.rawValue)"
            }
            return try client.run(PullImageEndpoint(imageName: identifier))
                .map({ response in
                    Image(id: name, digest: .init(response.digest), repoTags: tag.map({ ["\(name.value):\($0)"] }))
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
    }
}

extension Image {
    public func remove(on client: DockerClient, force: Bool=false) throws -> EventLoopFuture<Void> {
        try client.images.remove(image: self, force: force)
    }
}
