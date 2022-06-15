import Foundation
import BetterCodable

/// Representation of an image.
/// Some actions can be performed on an instance.
public struct Image : Codable {
    
    /// Local ID of the image.
    public let id: String
    
    /// ID of the parent image.
    public let parentId: String
    
    /// Names and tags of the image that it has in the repository.
    public let repoTags: [String]?
    
    /// List of content-addressable digests of locally available image manifests that the image is referenced from. Multiple manifests can refer to the same image.
    /// These digests are usually only available if the image was either pulled from a registry, or if the image was pushed to a registry, which is when the manifest is generated and its digest calculated.
    public let repoDigests: [String]?
    
    /// Optional message that was set when committing or importing the image.
    public let comment: String
    
    /// The ID of the container that was used to create the image.
    /// Depending on how the image was created, this field may be empty.
    public let containerId: String
    
    /// Configuration for a container that is portable between hosts.
    public let containerConfig: ContainerConfig
    
    /// Configuration for a container that is portable between hosts.
    //public let config: ContainerConfig

    /// Date when the image was created.
    /// This is **not** the date when the image was pulled.
    public var created: Date
    
    /// The version of Docker that was used to build the image.
    /// Depending on how the image was created, this field may be empty.
    public let dockerVersion: String
    
    /// Name of the author that was specified when committing the image, or as specified through 1MAINTAINER1 (deprecated) in the Dockerfile.
    public let author: String
    
    /// Hardware CPU architecture that the image runs on.
    public let architecture: String
    
    /// CPU architecture variant (presently ARM-only).
    public let variant: String?
    
    /// Operating System the image is built to run on.
    public let os: String
    
    /// Operating System version the image is built to run on (especially for Windows).
    public let osVersion: String?
    
    /// Total size of the image, including all its layers
    public let size: UInt64
    
    /// Equivalent of the `size` field.
    /// This field is kept for backward compatibility, but may be removed in a future version of the API.
    public let virtualSize: UInt64
    
    //public let sharedSize: Int
    
    public let labels: [String:String]?
    
    /// Information about the storage driver used to store the container's and image's filesystem.
    public let graphDriver: GraphDriverData
    
    public let rootFs: RootFS
    
    // public let Metadata
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case parentId = "Parent"
        case repoTags = "RepoTags"
        case repoDigests = "RepoDigests"
        case created = "Created"
        case comment = "Comment"
        case containerId = "Container"
        case containerConfig = "ContainerConfig"
        //case config = "Config"
        case dockerVersion = "DockerVersion"
        case author = "Author"
        case architecture = "Architecture"
        case variant = "Variant"
        case os = "Os"
        case osVersion = "OsVersion"
        case size = "Size"
        case virtualSize = "VirtualSize"
        //case sharedSize = "SharedSize"
        case labels = "Labels"
        case graphDriver = "GraphDriver"
        case rootFs = "RootFS"
    }
    
    public struct GraphDriverData: Codable {
        public let name: String?
        
        /// Driver-specific options for the selectd log driver, specified as key/value pairs.
        public let data: [String:String]?
        
        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case data = "Data"
        }
    }
    
    public struct RootFS: Codable {
        public let `type`: String
        public let layers: [String]
        
        enum CodingKeys: String, CodingKey {
            case `type` = "Type"
            case layers = "Layers"
        }
    }
}

/*extension Image.RepositoryTag {
    init?(_ value: String) {
        guard !value.hasPrefix("sha256") else { return nil }
        let components = value.split(separator: ":").map(String.init)
        if components.count == 2 {
            self.repository =  components[0]
            self.tag = components[1]
        } else if components.count == 1 {
            self.repository = value
        } else {
            return nil
        }
    }
}

extension Image.RepositoryTag: Codable {}*/
