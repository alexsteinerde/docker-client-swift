import Foundation

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
}

extension Image.RepositoryTag {
    init?(_ value: String) {
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
