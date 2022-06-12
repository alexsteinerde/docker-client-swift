import NIOHTTP1
import Foundation

struct TagImageEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = NoBody
    var method: HTTPMethod = .POST
    
    private let nameOrId: String
    private let repoName: String
    private let tag: String
    
    var path: String {
        "images/\(nameOrId)/tag?repo=\(repoName)&tag=\(tag)"
    }
    
    init(nameOrId: String, repoName: String, tag: String) {
        self.nameOrId = nameOrId
        self.repoName = repoName
        self.tag = tag
    }
}
