import Foundation

/// Represents a Docker build output message
public struct BuildStreamOutput: Codable {
    /// Raw message from the Docker builder
    public let stream: String?
    
    /// Additional information. Used to return the built Image ID.
    public let aux: AuxInfo?
    
    /// Set if build error, nil otherwise
    public let message: String?
    
    public struct AuxInfo: Codable {
        /// The ID of the built image
        public let id: String
        
        enum CodingKeys: String, CodingKey {
            case id = "ID"
        }
    }
}
