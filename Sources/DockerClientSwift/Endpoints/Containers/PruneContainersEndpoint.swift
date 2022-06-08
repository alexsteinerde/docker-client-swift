import NIOHTTP1

struct PruneContainersEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = PruneContainersResponse
    typealias Body = NoBody
    var method: HTTPMethod = .POST

    init() {
        
    }
    
    var path: String {
        "containers/prune"
    }
    
    struct PruneContainersResponse: Codable {
        let ContainersDeleted: [String]?
        let SpaceReclaimed: UInt64
    }
}
