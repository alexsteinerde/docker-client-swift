import Foundation

public struct ContainerFsChange: Codable {
    /// Path to file that has changed
    public let path: String
    
    public let kind: FsChangeKind
    
    enum CodingKeys: String, CodingKey {
        case path = "Path"
        case kind = "Kind"
    }
    
    public enum FsChangeKind: Int, Codable {
        case modified = 0
        case added = 1
        case deleted = 2
    }
}
