import Foundation
import NIOHTTP1

struct WaitContainerEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = ContainerWaitResponse
    var method: HTTPMethod = .POST
    
    let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "containers/\(nameOrId)/wait"
    }
    
    struct ContainerWaitResponse: Codable {
        let StatusCode: Int
    }
}
