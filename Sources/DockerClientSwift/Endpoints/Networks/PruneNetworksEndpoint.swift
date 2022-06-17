import NIOHTTP1
import Foundation

struct PruneNetworksEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = PrunedNetworks
    typealias Body = NoBody
    var method: HTTPMethod = .POST
    
    init() {}
    
    var path: String {
        "networks/prune"
    }
    
    
    struct PrunedNetworks: Codable {
        let NetworksDeleted: [String]
    }
}

