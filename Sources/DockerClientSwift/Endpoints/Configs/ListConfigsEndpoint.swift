import Foundation
import NIOHTTP1

struct ListConfigsEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [Config]
    var method: HTTPMethod = .GET
    
    init() {
    }
    
    var path: String {
        "configs"
    }
}
