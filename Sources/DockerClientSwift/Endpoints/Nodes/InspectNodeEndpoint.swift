import Foundation
import NIOHTTP1

struct InspectNodeEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = SwarmNode
    var method: HTTPMethod = .GET
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    var path: String {
        "nodes/\(id)"
    }
}
