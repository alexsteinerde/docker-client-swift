import Foundation

extension DockerClient {
    
    /// APIs related to Docker configs.
    public var configs: ConfigsAPI {
        .init(client: self)
    }
    
    public struct ConfigsAPI {
        fileprivate var client: DockerClient
        
        /// Lists the configs.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  a  list of `Config`.
        public func list() async throws -> [Config] {
            return try await client.run(ListConfigsEndpoint())
        }
        
        
        /// Gets a Config by a given name or id.
        /// - Parameter nameOrId: Name or id of a `Config` that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return the `Config`.
        public func get(_ nameOrId: String) async throws -> Config {
            return try await client.run(InspectConfigEndpoint(nameOrId: nameOrId))
        }
        
        /// Create a new Config.
        /// - Parameters:
        ///   - spec: configuration as a `ConfigSpec`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Config`.
        public func create(spec: ConfigSpec) async throws -> Config {
            let createResponse = try await client.run(CreateConfigEndpoint(spec: spec))
            return try await client.configs.get(createResponse.ID)
        }
        
        
        /// Removes an existing Config.
        /// - Parameters:
        ///   - nameOrId: Name or Id of the`config`.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(_ nameOrId: String) async throws {
            try await client.run(RemoveConfigEndpoint(nameOrId: nameOrId))
        }
        
    }
}
