import Foundation

extension DockerClient {
    
    /// APIs related to Docker registries.
    public var registries: RegistriesAPI {
        .init(client: self)
    }
    
    public struct RegistriesAPI {
        fileprivate var client: DockerClient
        
        /// Log into a docker registry (gets a token)
        /// - Parameters:
        ///   - credentials: configuration as a `RegistryAuth`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the `RegistryAuth` passed as a parameter, with the `token` field set if authentication was successful.
        public func login(credentials: inout RegistryAuth) async throws -> RegistryAuth {
            let response = try await client.run(RegistryLoginEndpoint(credentials: credentials))
            if response.IdentityToken != "" {
                credentials.token = response.IdentityToken
            }
            else { // use the credentials themselves
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(credentials) 
                credentials.token = encoded.base64EncodedString()
            }
            return credentials
        }
        
    }
}
