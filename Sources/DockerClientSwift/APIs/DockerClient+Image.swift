import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to images.
    public var images: ImagesAPI {
        .init(client: self)
    }
    
    public struct ImagesAPI {
        fileprivate var client: DockerClient
        
        /// Pulls an image by it's name. If a tag or digest is specified these are fetched as well.
        /// If you want to customize the identifier of the image you can use `pullImage(byIdentifier:)` to do this.
        /// - Parameters:
        ///   - name: Image name that is fetched
        ///   - tag: Optional tag name. Default is `nil`.
        ///   - digest: Optional digest value. Default is `nil`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Fetches the latest image information and returns the `Image` that has been fetched.
        public func pullImage(byName name: String, tag: String? = nil, digest: Digest? = nil) async throws -> Image {
            var identifier = name
            if let tag = tag {
                identifier += ":\(tag)"
            }
            if let digest = digest {
                identifier += "@\(digest.rawValue)"
            }
            return try await pullImage(byIdentifier: identifier)
        }
        
        /// Pulls an image by a given identifier. The identifier can be build manually.
        /// - Parameter identifier: Identifier of an image that is pulled.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Fetches the latest image information and returns the `Image` that has been fetched.
        public func pullImage(byIdentifier identifier: String) async throws -> Image {
            try await client.run(PullImageEndpoint(imageName: identifier))
            return try await self.get(identifier)
        }
        
        /// Push an image to a registry.
        /// - Parameters:
        ///   - nameOrId: Name or ID of the `Image` that should be pushed.
        ///   - tag: The tag to associate with the image on the registry. If you wish to push an image on to a private registry, that image must already have a tag which references the registry. For example, registry.example.com/myimage:latest.
        /// - Throws: Errors that can occur when executing the request.
        public func push(_ nameOrId: String, tag: String? = nil) async throws {
            try await client.run(PushImageEndpoint(nameOrId: nameOrId, tag: tag))
        }
        
        /// Gets all images in the Docker system.
        /// - Parameter all: If `true` intermediate image layer will be returned as well. Default is `false`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a list of `Image` instances.
        public func list(all: Bool = false) async throws -> [ImageSummary] {
            return try await client.run(ListImagesEndpoint(all: all))
        }
        
        /// Removes an image. By default only unused images can be removed. If you set `force` to `true` the image will also be removed if it is used.
        /// - Parameters:
        ///   - nameOrId: Name or ID of an `Image` that should be removed.
        ///   - force: Should the image be removed by force? If `false` the image will only be removed if it's unused. If `true` existing containers will break. Default is `false`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` when the image has been removed or an error is thrown.
        public func remove(_ nameOrId: String, force: Bool = false) async throws {
            try await client.run(RemoveImageEndpoint(nameOrId: nameOrId, force: force))
        }
        
        /// Fetches the current information about an image from the Docker system.
        /// - Parameter nameOrId: Name or id of an image that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the `Image` data.
        public func get(_ nameOrId: String) async throws -> Image {
            return try await client.run(InspectImagesEndpoint(nameOrId: nameOrId))
        }
        
        
        // WIP
        /// Builds an image.
        /// - Parameters:
        ///   - config: A `BuildConfig` instance specifying build options.
        ///   - context: A `ByteBuffer` containing a **TAR archive** of the Docker Build context (Dockerfile + any other content needed to build the image).
        ///   - timeout: How long to wait for the build to finish before cancelling it (by cancelling the request).
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` when the image has been removed or an error is thrown.
        public func build(config: BuildConfig, context: ByteBuffer, timeout: TimeAmount = .minutes(10)) async throws -> AsyncThrowingStream<BuildStreamOutput, Error> {
            let endpoint = BuildEndpoint(buildConfig: config, context: context)
            let response =  try await client.run(endpoint, timeout: timeout)
            return try await endpoint.map(response: response)
            
        }
        
        /// Tags an image.
        /// - Parameters:
        ///   - nameOrId: Name or ID of the image to tag.
        ///   - repoName: The repository name. (can optionally start with a registry endpoint)
        ///   - tag: The tag name. Defaults to "latest"..
        /// - Throws: Errors that can occur when executing the request.
        public func tag(_ nameOrId: String, repoName: String, tag: String = "latest") async throws {
            try await client.run(TagImageEndpoint(nameOrId: nameOrId, repoName: repoName, tag: tag))
        }
        
        /// Deletes all unused images.
        /// - Parameter all: When set to `true`, prune only unused and untagged images. When set to `false`, all unused images are pruned.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` with `PrunedImages` details about removed images and the reclaimed space.
        public func prune(all: Bool = false) async throws -> PrunedImages {
            let response = try await client.run(PruneImagesEndpoint(dangling: !all))
            return PrunedImages(
                imageIds: response.ImagesDeleted?.compactMap(\.Deleted) ?? [],
                reclaimedSpace: response.SpaceReclaimed
            )
        }
        
        public struct PrunedImages {
            /// IDs of the images that got deleted.
            let imageIds: [String]
            
            /// Disk space reclaimed in bytes.
            let reclaimedSpace: UInt64
        }
    }
}


/*extension Image {
    /// Parses an image identifier to it's corresponding digest, name and tag.
    /// - Parameter value: Image identifer.
    /// - Returns: Returns an `Optional` tuple of a `Digest` and a `RepositoryTag`.
    internal static func parseNameTagDigest(_ value: String) -> (Digest, RepositoryTag)? {
        let components = value.split(separator: "@").map(String.init)
        if components.count == 2, let nameTag = RepositoryTag(components[0]) {
            return (.init(components[1]), nameTag)
        } else {
            return nil
        }
    }
}*/
