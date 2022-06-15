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
        
        /// Creates a new Secret.
        /// - Parameters:
        ///   - spec: configuration as a `SecretSpec`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the newly created `Secret`.
        public func create(spec: SecretSpec) async throws -> Secret {
            let createResponse = try await client.run(CreateSecretEndpoint(spec: spec))
            return try await client.secrets.get(createResponse.ID)
        }
        
        /// Updates a Secret. Currently, only the `labels` field can be updated (Docker limitation)
        /// - Parameters:
        ///   - nameOrId: Name or ID of the `Secret` that should be updated.
        ///   - labels: new labels to set.
        /// - Throws: Errors that can occur when executing the request.
        public func update(_ nameOrId: String, labels: [String:String]) async throws {
            let secret = try await get(nameOrId)
            try await client.run(
                UpdateSecretEndpoint(
                    nameOrId: secret.id,
                    version: secret.version.index,
                    spec: .init(
                        name: secret.spec.name,
                        data: secret.spec.data,
                        labels: labels,
                        templating: secret.spec.templating
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
