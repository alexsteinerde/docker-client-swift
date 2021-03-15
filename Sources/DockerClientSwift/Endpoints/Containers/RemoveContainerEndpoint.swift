import NIOHTTP1

struct RemoveContainerEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .DELETE
    
    private let containerId: String
    
    init(containerId: String) {
        self.containerId = containerId
    }
    
    var path: String {
        "containers/\(containerId)"
    }
}
