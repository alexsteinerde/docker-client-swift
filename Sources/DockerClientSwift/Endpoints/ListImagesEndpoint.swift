import NIOHTTP1

struct ListImagesEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [ImageResponse]
    var method: HTTPMethod = .GET
    
    private var all: Bool
    
    init(all: Bool) {
        self.all = all
    }
    
    var path: String {
        "images/json?all=\(all)"
    }
    
    struct ImageResponse: Codable {
        let Id: String
        let ParentId: String
        let RepoTags: [String]?
        let RepoDigests: [String]?
        let Created: Int
        let Size: Int
        let VirtualSize: Int
        let SharedSize: Int
        let Containers: Int
        // TODO: Add additional fields
    }
}
