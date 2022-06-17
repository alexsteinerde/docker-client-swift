import NIOHTTP1
import Foundation

struct PushImageEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = NoBody
    var method: HTTPMethod = .POST
    
    let nameOrId: String
    let tag: String?
    
    var path: String {
        "images/\(nameOrId)/push\(tag != nil ? "?tag=\(tag!)" : "")"
    }
    
    init(nameOrId: String, tag: String? = nil) {
        self.nameOrId = nameOrId
        self.tag = tag
    }
}
