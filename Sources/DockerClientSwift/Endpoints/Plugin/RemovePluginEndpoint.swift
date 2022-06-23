import NIOHTTP1

struct RemovePluginEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = NoBody?
    
    var method: HTTPMethod = .DELETE
    var path: String {
        "plugins/\(name)?force=\(force)"
    }
    
    private let name: String
    private let force: Bool
    
    init(name: String, force: Bool) {
        self.name = name
        self.force = force
    }
}
