import NIOHTTP1

struct ListContainersEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [ContainerResponse]
    var method: HTTPMethod = .GET
    
    private var all: Bool
    
    init(all: Bool) {
        self.all = all
    }
    
    var path: String {
        "containers/json?all=\(all)"
    }
    
    struct ContainerResponse: Codable {
        let Id: String
        let Names: [String]
        let Image: String
        let ImageID: String
        let Command: String
        let Created: Int
        let State: String
        let Status: String
        // TODO: Add additional fields
    }
}
