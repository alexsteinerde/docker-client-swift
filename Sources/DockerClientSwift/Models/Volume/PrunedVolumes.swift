import Foundation

public struct PrunedVolumes: Codable {
    let volumesDeleted: [String]?
    let spaceReclaimed: UInt64
    
    enum CodingKeys: String, CodingKey {
        case volumesDeleted = "VolumesDeleted"
        case spaceReclaimed = "SpaceReclaimed"
    }
}
