import NIOHTTP1

struct ListContainersEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [ContainerSummary]
    var method: HTTPMethod = .GET
    
    private var all: Bool
    
    init(all: Bool) {
        self.all = all
    }
    
    var path: String {
        "containers/json?all=\(all)"
    }
}
