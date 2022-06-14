import Foundation

extension DockerClient {
    
    /// APIs related to Docker configs.
    public var secrets: SecretsAPI {
        .init(client: self)
    }
    
    public struct SecretsAPI {
        fileprivate var client: DockerClient
        
        /// Lists the secrets.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns  a  list of `Secret`.
        public func list() async throws -> [Secret] {
            return try await client.run(ListSecretsEndpoint())
        }
        
        
        /// Gets a Secret by a given name or id.
        /// - Parameter nameOrId: Name or id of a `Config` that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return the `Secret`.
        public func get(_ nameOrId: String) async throws -> Secret {
            return try await client.run(InspectSecretEndpoint(nameOrId: nameOrId))
        }
        
        /// Create a new Secret.
        /// - Parameters:
        ///   - spec: configuration as a `SecretSpec`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Secret`.
        public func create(spec: SecretSpec) async throws -> Secret {
            let createResponse = try await client.run(CreateSecretEndpoint(spec: spec))
            return try await client.secrets.get(createResponse.ID)
        }
        
        /// Update a Secret. Currently, only the `labels` field can be updated (Docker limitation)
        /// - Parameters:
        ///   - nameOrId: Name or ID of the `Secret` that should be updated.
        ///   - version: Current version of the `Secret` that should be updated. Can be obtained by calling get()
        ///   - labels: new labels to set.
        /// - Throws: Errors that can occur when executing the request.
        public func update(_ nameOrId: String, version: UInt64, labels: [String:String]) async throws {
            let config = try await get(nameOrId)
            try await client.run(
                UpdateSecretEndpoint(
                    nameOrId: config.id,
                    version: version,
                    spec: .init(
                        name: config.spec.name,
                        data: config.spec.data,
                        labels: labels,
                        templating: config.spec.templating
                    )
                )
            )
        }
        
        /// Removes an existing Secret.
        /// - Parameters:
        ///   - nameOrId: Name or Id of the`config`.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(_ nameOrId: String) async throws {
            try await client.run(RemoveSecretEndpoint(nameOrId: nameOrId))
        }
        
    }
}
