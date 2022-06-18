import Foundation

public struct PrunedVolumes: Codable {
    /// The **names** of the volumes that got deleted.
    let volumesDeleted: [String]
    
    /// The space the was freed, in bytes
    let spaceReclaimed: UInt64
    
    enum CodingKeys: String, CodingKey {
        case volumesDeleted = "VolumesDeleted"
        case spaceReclaimed = "SpaceReclaimed"
    }
}
