import NIOHTTP1

struct StartContainerEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .POST
    
    private let containerId: String
    
    init(containerId: String) {
        self.containerId = containerId
    }
    
    var path: String {
        "containers/\(containerId)/start"
    }
}
