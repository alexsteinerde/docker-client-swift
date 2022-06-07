import Foundation
import BetterCodable

/// Basic Container information returned when listing containers
public struct ContainerSummary: Codable {
    public let id: String
    public let names: [String]
    public let image: String
    public let imageId: String
    public let command: String
    
    @DateValue<TimestampStrategy>
    private(set)public var createdAt: Date
    
    public let ports: [UInt16]
    
    public let labels: [String:String]
    
    public let state: State
    
    public let status: String
    
    // TODO: HostConfig
    // TODO: NetworkSettings
    
    public enum State: String, Codable {
        case created, restarting, running, removing, paused, exited, dead
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
