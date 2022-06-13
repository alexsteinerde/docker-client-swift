import Foundation
import NIOHTTP1

struct ListNetworksEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [Network]
    var method: HTTPMethod = .GET
    
    init() {
    }
    
    var path: String {
        "networks"
    }
}
