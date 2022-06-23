import Foundation
import NIOHTTP1

struct ListPluginsEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [Plugin]
    var method: HTTPMethod = .GET
    
    init() {}
    
    var path: String {
        "plugins"
    }
}
