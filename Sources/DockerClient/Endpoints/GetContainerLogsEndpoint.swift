import NIOHTTP1

struct GetContainerLogsEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = String
    var method: HTTPMethod = .GET
    
    private let containerId: String
    
    init(containerId: String) {
        self.containerId = containerId
    }
    
    var path: String {
        "containers/\(containerId)/logs?stdout=true&stderr=true"
    }
}
