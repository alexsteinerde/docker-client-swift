import Foundation

public struct Network: Codable {
    /// The network's name.
    public let name: String
    
    public let id: String
    
    public let createdAt: Date
    
    /// `local` (this Docker host only) or `swarm` (available in the whole cluster)
    public let scope: DockerScope
    
    /// Name of the network driver plugin to use.
    public let driver: String?
    
    /// Restrict external access to the network.
    public let `internal`: Bool
    
    /// Globally scoped network is manually attachable by regular containers from workers in swarm mode.
    public let attachable: Bool
    
    /// Ingress network is the network which provides the routing-mesh in swarm mode.
    public let ingress: Bool
    
    public let ipam: IPAM
    
    /// Enable IPv6 on the network.
    public let enableIPv6: Bool
    
    public let containers: [String:NetworkContainer]?
    
    /// Network specific options to be used by the drivers.
    public let options: [String:String]
    
    /// User-defined key/value metadata.
    public let labels: [String:String]?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case id = "Id"
        case createdAt = "Created"
        case scope = "Scope"
        case driver = "Driver"
        case `internal` = "Internal"
        case attachable = "Attachable"
        case ingress = "Ingress"
        case ipam = "IPAM"
        case enableIPv6 = "EnableIPv6"
        case containers = "Containers"
        case options = "Options"
        case labels = "Labels"
    }
    
    public struct NetworkContainer: Codable {
        public let name: String
        public let endpointId: String
        public let macAddress: String
        public let ipv4Address: String
        public let ipv6Address: String
        
        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case endpointId = "EndpointID"
            case macAddress = "MacAddress"
            case ipv4Address = "IPv4Address"
            case ipv6Address = "IPv6Address"
        }
    }
}
