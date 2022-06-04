import NIOHTTP1
import Foundation

public struct LeaveSwarmEndpoint: Endpoint {
    
    typealias Body = NoBody
    typealias Response = NoBody
    var method: HTTPMethod = .POST
    
    var path: String {
        "swarm/leave?force=\(force)"
    }
    
    private let force: Bool
    
    init(force: Bool = false) {
        self.force = force
    }
}
