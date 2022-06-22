import Foundation
import BetterCodable

/// Basic Container information returned when listing containers
public struct ContainerSummary: Codable {
    public let id: String
    
    /// The names that this container has been given
    public let names: [String]
    
    /// The name of the image used when creating this container
    public let image: String
    
    /// The ID of the image that this container was created from
    public let imageId: String
    
    /// Command to run when starting the container
    public let command: String
    
    /// When the container was created
    @DateValue<TimestampStrategy>
    private(set)public var createdAt: Date
    
    /// The ports exposed by this container
    public let ports: [ExposedPort]
    
    public let labels: [String:String]
    
    /// The state of this container (e.g. `exited`)
    public let state: Container.State.State
    
    /// Additional human-readable status of this container (e.g. "Exit 0")
    public let status: String
    
    // TODO: HostConfig
    // TODO: NetworkSettings
    
    
    public struct ExposedPort: Codable {
        public let ip: String?
        public let privatePort: UInt16
        public let publicPort: UInt16?
        public let type: ExposedPortSpec.PortProtocol
        
        enum CodingKeys: String, CodingKey {
            case ip = "IP"
            case privatePort = "PrivatePort"
            case publicPort = "PublicPort"
            case type = "Type"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case names = "Names"
        case image = "Image"
        case imageId = "ImageID"
        case command = "Command"
        case createdAt = "Created"
        case ports = "Ports"
        case labels = "Labels"
        case state = "State"
        case status = "Status"
    }
}
