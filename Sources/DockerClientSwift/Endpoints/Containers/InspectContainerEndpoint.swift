import Foundation
import NIOHTTP1

struct InspectContainerEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = Container
    var method: HTTPMethod = .GET
    
    let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "containers/\(nameOrId)/json"
    }
    
}
