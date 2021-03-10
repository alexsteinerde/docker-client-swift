import NIOHTTP1

struct StopContainerEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .POST
    
    private let containerId: String
    
    init(containerId: String) {
        self.containerId = containerId
    }
    
    var path: String {
        "containers/\(containerId)/stop"
    }
}
