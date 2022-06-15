import Foundation
import NIOHTTP1

struct GetContainerChangesEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [ContainerFsChange]
    var method: HTTPMethod = .GET
    
    let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "containers/\(nameOrId)/changes/json"
    }
}
