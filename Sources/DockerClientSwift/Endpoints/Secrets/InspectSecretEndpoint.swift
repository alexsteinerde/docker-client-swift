import Foundation
import NIOHTTP1

struct InspectSecretEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = Secret
    var method: HTTPMethod = .GET
    
    private let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "secrets/\(nameOrId)"
    }
}
