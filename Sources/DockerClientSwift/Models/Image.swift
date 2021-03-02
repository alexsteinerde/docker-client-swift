import Foundation

public struct Image {
    internal init(id: Identifier<Image>, digest: Digest? = nil, repoTags: [String]?=nil, createdAt: Date?=nil) {
        self.id = id
        self.digest = digest
        self.createdAt = createdAt
        
        repositoryTags = repoTags.map({ repoTags in
            repoTags.compactMap { repoTag in
                let components = repoTag.split(separator: ":").map(String.init)
                if components.count == 2 {
                    return RepositoryTag(repository: components[0], tag: components[1])
                } else {
                    return nil
                }
            }
        }) ?? []
    }
    
    /// Local ID of the image. This can vary from instant to instant.
    public var id: Identifier<Image>
    
    /// The unique hash of the image layer that is exposed. Format: {hash algorithm}:{hash value}.
    public var digest: Digest?
    
    /// Names and tags of the image that it has in the repository.
    public var repositoryTags: [RepositoryTag]
    
    /// Date when the image was created.
    public var createdAt: Date?
    
    public struct RepositoryTag {
        var repository: String
        var tag: String
    }
}
