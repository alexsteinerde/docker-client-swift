import NIOHTTP1

struct EnableDisablePluginEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .POST
    
    private let name: String
    // if `false`, will disable
    private let enable: Bool
    
    init(name: String, enable: Bool) {
        self.name = name
        self.enable = enable
    }
    
    var path: String {
        "plugins/\(name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)/\(enable ? "enable" : "disable")?timeout=30"
    }
}
