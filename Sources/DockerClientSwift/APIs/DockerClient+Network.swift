import Foundation

extension DockerClient {
    
    /// APIs related to Docker networks.
    public var networks: NetworksAPI {
        .init(client: self)
    }
    
    public struct NetworksAPI {
        fileprivate var client: DockerClient
        
        /// Lists the networks.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  a  list of `Network`.
        public func list() async throws -> [Network] {
            return try await client.run(ListNetworksEndpoint())
        }
        
        
        /// Gets a Network by a given name or id.
        /// - Parameter nameOrId: Name or id of a `Network` that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return the `Network`.
        public func get(_ nameOrId: String) async throws -> Network {
            return try await client.run(InspectNetworkEndpoint(nameOrId: nameOrId))
        }
        /*
        /// Create a new Volume.
        /// - Parameters:
        ///   - spec: configuration as a `VolumeSpec`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Volume`.
        public func create(spec: VolumeSpec) async throws -> Volume {
            return try await client.run(CreateVolumeEndpoint(spec: spec))
        }
        
        /// Removes an existing Volume.
        /// - Parameters:
        ///   - nameOrId: Name or Id of the`Volume`.
        ///   - force: Force removal.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(_ nameOrId: String, force: Bool = false) async throws {
            try await client.run(RemoveVolumeEndpoint(nameOrId: nameOrId, force: force))
        }
        
        /// Deletes all unused volumes.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a `PrunedVolumes` details about removed volumes and the reclaimed space.
        public func prune(all: Bool = false) async throws -> PrunedVolumes {
            return try await client.run(PruneVolumesEndpoint())
        }
         */
    }
}
