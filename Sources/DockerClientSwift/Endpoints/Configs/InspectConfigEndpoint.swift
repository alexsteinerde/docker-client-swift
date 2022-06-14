import Foundation
import NIOHTTP1

struct InspectConfigEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = Config
    var method: HTTPMethod = .GET
    
    private let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "configs/\(nameOrId)"
    }
}
