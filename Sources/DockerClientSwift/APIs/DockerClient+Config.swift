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
        
        /// Creates a new Config.
        /// - Parameters:
        ///   - spec: configuration as a `ConfigSpec`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Config`.
        public func create(spec: ConfigSpec) async throws -> Config {
            let createResponse = try await client.run(CreateConfigEndpoint(spec: spec))
            return try await client.configs.get(createResponse.ID)
        }
        
        /// Updates a  Config. Currently, only the `labels` field can be updated (Docker limitation)
        /// - Parameters:
        ///   - nameOrId: Name or ID of the `Config` that should be updated.
        ///   - labels: new labels to set.
        /// - Throws: Errors that can occur when executing the request.
        public func update(_ nameOrId: String, labels: [String:String]) async throws {
            let config = try await get(nameOrId)
            try await client.run(
                UpdateConfigEndpoint(
                    nameOrId: config.id,
                    version: config.version.index,
                    spec: .init(
                        name: config.spec.name,
                        data: config.spec.data,
                        labels: labels,
                        templating: config.spec.templating
                    )
                )
            )
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
