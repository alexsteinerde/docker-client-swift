import Foundation
import NIOHTTP1

struct GetPluginPrivilegesEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [PluginPrivilege]
    var method: HTTPMethod = .GET
    
    private let remote: String
    
    init(remote: String) {
        self.remote = remote
    }
    
    var path: String {
        "plugins/privileges?remote=\(remote)"
    }
}
