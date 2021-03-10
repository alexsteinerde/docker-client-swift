import NIOHTTP1

struct RemoveImageEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .DELETE
    
    private let imageId: String
    private let force: Bool
    
    init(imageId: String, force: Bool=false) {
        self.imageId = imageId
        self.force = force
    }
    
    var path: String {
        "images/\(imageId)?force=\(force ? "true" : "false")"
    }
}
