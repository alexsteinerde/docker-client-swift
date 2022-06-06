import Foundation

/// Basic Container information returned when listing containers
public struct ContainerSummary: Codable {
    public let id: String
    public let names: [String]
    public let image: String
    public let imageId: String
    public let command: String
    
    // date
    public let createdAt: UInt64
    
    public let ports: [UInt16]
    
    public let labels: [String:String]
    
    public let state: String
    
    public let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
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
