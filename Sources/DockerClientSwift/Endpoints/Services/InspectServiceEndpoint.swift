import Foundation
import NIOHTTP1

struct InspectServiceEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = Service
    var method: HTTPMethod = .GET
    
    private let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "services/\(nameOrId)?insertDefaults=true"
    }
}
