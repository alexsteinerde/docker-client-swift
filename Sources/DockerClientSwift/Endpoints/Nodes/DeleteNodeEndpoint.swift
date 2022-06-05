import Foundation
import NIOHTTP1

struct DeleteNodeEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = NoBody
    var method: HTTPMethod = .DELETE
    
    let id: String
    let force: Bool
    
    init(id: String, force: Bool) {
        self.id = id
        self.force = force
    }
    
    var path: String {
        "nodes/\(id)?force=\(force)"
    }
}
