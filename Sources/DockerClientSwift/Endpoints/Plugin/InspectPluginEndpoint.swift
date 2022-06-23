import Foundation
import NIOHTTP1

struct InspectPluginEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = Plugin
    var method: HTTPMethod = .GET
    
    private let name: String
    
    init(name: String) {
        self.name = name
    }
    
    var path: String {
        "plugins/\(name)/json"
    }
}
