import Foundation
import BetterCodable

/// Brief info about an image, returned when listing images.
public struct ImageResponse: Codable {
    public let id: String
    public let parentId: String
    public let repoTags: [String]?
    public let repoDigests: [String]?
    
    /// Date when the image was created.
    /// This is **not** the date when the image was pulled.
    @DateValue<TimestampStrategy>
    public var created: Date
    
    public let size: Int
    public let virtualSize: Int
    public let sharedSize: Int
    public let labels: [String:String]? = [:]
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

/// Representation of an image.
/// Some actions can be performed on an instance.
public struct Image {

    /// Local ID of the image. This can vary from instant to instant.
    public var id: Identifier<Image>

    /// The unique hash of the image layer that is exposed. Format: {hash algorithm}:{hash value}.
    public var digest: Digest?

    /// Names and tags of the image that it has in the repository.
    public var repositoryTags: [RepositoryTag]

    /// Date when the image was created.
    public var createdAt: Date?

    public struct RepositoryTag {
        public var repository: String
        public var tag: String?
    }

    internal init(id: Identifier<Image>, digest: Digest? = nil, repoTags: [String]?=nil, createdAt: Date?=nil) {
        let repositoryTags = repoTags.map({ repoTags in
            repoTags.compactMap { repoTag in
                return RepositoryTag(repoTag)
            }
        }) ?? []

        self.init(id: id, digest: digest, repositoryTags: repositoryTags, createdAt: createdAt)
    }

    internal init(id: Identifier<Image>, digest: Digest? = nil, repositoryTags: [RepositoryTag]?=nil, createdAt: Date?=nil) {
        self.id = id
        self.digest = digest
        self.createdAt = createdAt
        self.repositoryTags = repositoryTags ?? []
    }

    internal init(id: Identifier<Image>) {
        self.id = id
        self.repositoryTags = []
    }
}

extension Image.RepositoryTag {
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

extension Image: Codable {}
extension Image.RepositoryTag: Codable {}
