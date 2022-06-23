import Foundation
import BetterCodable

/// Brief info about an image, returned when listing images.
public struct ImageSummary: Codable {
    /// Local ID of the image.
    public let id: String
    
    /// ID of the parent image.
    public let parentId: String
    
    /// Names and tags of the image that it has in the repository.
    public let repoTags: [String]?
    
    /// List of content-addressable digests of locally available image manifests that the image is referenced from. Multiple manifests can refer to the same image.
    /// These digests are usually only available if the image was either pulled from a registry, or if the image was pushed to a registry, which is when the manifest is generated and its digest calculated.
    public let repoDigests: [String]?
    
    /// Date when the image was created.
    /// This is **not** the date when the image was pulled.
    @DateValue<TimestampStrategy>
    public var created: Date
    
    /// Total size of the image, including all its layers
    public let size: UInt64
    
    /// Equivalent of the `size` field.
    /// This field is kept for backward compatibility, but may be removed in a future version of the API.
    public let virtualSize: UInt64
    
    
    public let sharedSize: Int
    
    /// User-defined key/value metadata.
    public let labels: [String:String] = [:]
    
    public let containers: Int
    
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case parentId = "ParentId"
        case repoTags = "RepoTags"
        case repoDigests = "RepoDigests"
        case created = "Created"
        case size = "Size"
        case virtualSize = "VirtualSize"
        case sharedSize = "SharedSize"
        case labels = "Labels"
        case containers = "Containers"
    }
}
