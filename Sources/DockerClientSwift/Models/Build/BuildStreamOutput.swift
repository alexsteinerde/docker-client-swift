import Foundation

/// Represents a Docker build output message
public struct BuildStreamOutput: Codable {
    /// Raw progress message from the Docker builder
    public let stream: String?
    
    /// Additional information. Used to return the built Image ID.
    public let aux: AuxInfo?
    
    public struct AuxInfo: Codable {
        public let id: String
        
        enum CodingKeys: String, CodingKey {
            case id = "ID"
        }
    }
}
