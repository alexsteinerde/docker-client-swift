import Foundation

/// Information to log into a Docker registry.
public struct RegistryAuth: Codable {
    
    public var username: String
    
    public var email: String? = nil
    
    /// The registry password.
    /// Note: when using the Docker Hub with 2FA enabled, you must create a Personal Access Token and use its value as the password.
    public var password: String
    
    /// The URL of the registry. Defaults to the Docker Hub.
    public var serverAddress: URL = URL(string: "https://index.docker.io/v1/")!
    
    /// The token obtained after logging into the registry
    internal(set) public var token: String? = nil
    
    public init(username: String, email: String? = nil, password: String, serverAddress: URL = URL(string: "https://index.docker.io/v1/")!) {
        self.username = username
        self.email = email
        self.password = password
        self.serverAddress = serverAddress
    }
}
