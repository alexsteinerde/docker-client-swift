import Foundation

public struct ContainerCreate: Codable {
    /// Configuration specific to the container, and independent from the host it is running on.
    internal var config: ContainerConfig?
    
    /// Host specific configuration for the container.
    internal var hostConfig: ContainerHostConfig
    
    enum CodingKeys: String, CodingKey {
        case hostConfig = "HostConfig"
    }
    
    internal init(config: ContainerConfig, hostConfig: ContainerHostConfig) {
        self.config = config
        self.hostConfig = hostConfig
    }
    
    public func encode(to encoder: Encoder) throws {
        
        print("\n••• \(Self.self).encode(): 1")
        try config.encode(to: encoder)
        print("\n••• \(Self.self).encode(): 2")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hostConfig, forKey: .hostConfig)
        print("\n••• \(Self.self).encode(): 3")
    }
    
    /*init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.hostConfig = try container.decode(ContainerHostConfig.self, forKey: .)
    }*/
}
