import Foundation

public struct ServiceEndpointSpec: Codable {
    public var mode: EndpointMode? = .vip
    
    public var ports: [EndpointPortConfig]? = []
    
    enum CodingKeys: String, CodingKey {
        case mode = "Mode"
        case ports = "Ports"
    }
    
    public enum EndpointMode: String, Codable {
        case vip, dnsrr
    }
    
    public struct EndpointPortConfig: Codable {
        
        public var name: String
        
        public var `protocol`: ExposedPortSpec.PortProtocol = .tcp
        
        /// The port inside the container.
        public var targetPort: UInt16
        
        /// The port on the swarm hosts.
        public var publishedPort: UInt16
        
        /// The mode in which port is published.
        /// - `ingress` makes the target port accessible on every node, regardless of whether there is a task for the service running on that node or not.
        /// - `host` bypasses the routing mesh and publish the port directly on the swarm node where that service is running.
        public var publishMode: EndpointPortPublishMode = .ingress
        
        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case `protocol` = "Protocol"
            case targetPort = "TargetPort"
            case publishedPort = "PublishedPort"
            case publishMode = "PublishMode"
        }
        
        public enum EndpointPortPublishMode: String, Codable {
            case ingress, host
        }
    }
}
