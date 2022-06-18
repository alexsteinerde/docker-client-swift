import Foundation
import NIOHTTP1

struct ListTasksEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [SwarmTask]
    var method: HTTPMethod = .GET
    
    init() {
    }
    
    var path: String {
        "tasks"
    }
}
