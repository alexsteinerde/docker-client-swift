import Foundation

public struct Config: Codable {
    public let id: String
    
    /// The version number of the object such as node, service, etc.
    /// This is needed to avoid conflicting writes. The client must send the version number along with the modified specification when updating these objects.
    public let version: SwarmVersion
    
    public let createdAt: Date
    
    public let updatedAt: Date
    
    public let spec: ConfigSpec
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case version = "Version"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case spec = "Spec"
    }
}
