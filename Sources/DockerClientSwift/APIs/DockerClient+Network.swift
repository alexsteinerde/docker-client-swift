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

        /// Create a new Network.
        /// - Parameters:
        ///   - spec: configuration as a `NetworkSpec`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Network`.
        public func create(spec: NetworkSpec) async throws -> Network {
            let createResponse = try await client.run(CreateNetworkEndpoint(spec: spec))
            return try await client.networks.get(createResponse.Id)
        }
    
        /// Removes an existing Network.
        /// - Parameters:
        ///   - nameOrId: Name or Id of the`Network`.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(_ nameOrId: String) async throws {
            try await client.run(RemoveNetworkEndpoint(nameOrId: nameOrId))
        }
        
        /// Deletes all unused networks.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the list of IDs of the networks that got deleted.
        public func prune(all: Bool = false) async throws -> [String] {
            return try await client.run(PruneNetworksEndpoint()).NetworksDeleted
        }
    }
}
