import Foundation
import NIOHTTP1

struct ContainerTopEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = ContainerTop
    var method: HTTPMethod = .GET
    
    let nameOrId: String
    let psArgs: String
    
    var path: String {
        "containers/\(nameOrId)/top?ps_args=\(psArgs)"
    }
    
    init(nameOrId: String, psArgs: String) {
        self.nameOrId = nameOrId
        self.psArgs = psArgs
    }
}
