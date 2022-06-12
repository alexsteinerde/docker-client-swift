import Foundation

public struct SwarmTask: Codable {
    public let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
    }
    
}
