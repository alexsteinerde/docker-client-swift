import Foundation
import NIOHTTP1

struct UpdateNodeEndpoint: Endpoint {
    typealias Body = SwarmNodeSpec
    typealias Response = NoBody
    var method: HTTPMethod = .POST
    
    var body: Body?
    let id: String
    let version: String
    
    init(id: String, version: String, spec: SwarmNodeSpec) {
        self.id = id
        self.version = version
        self.body = spec
    }
    
    var path: String {
        "nodes/\(id)/update?version=\(version)"
    }
}
