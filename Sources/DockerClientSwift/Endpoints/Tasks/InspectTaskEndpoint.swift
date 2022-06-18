import Foundation
import NIOHTTP1

struct InspectTaskEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = SwarmTask
    var method: HTTPMethod = .GET
    
    private let id: String
    
    init(id: String) {
        self.id = id
    }
    
    var path: String {
        "tasks/\(id)"
    }
}
