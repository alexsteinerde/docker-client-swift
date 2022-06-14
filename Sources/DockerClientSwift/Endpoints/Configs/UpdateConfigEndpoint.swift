import NIOHTTP1

struct UpdateConfigEndpoint: Endpoint {
    typealias Response = NoBody
    typealias Body = ConfigSpec
    var method: HTTPMethod = .POST
    
    var body: Body?
    
    private let nameOrId: String
    private let version: UInt64
    
    init(nameOrId: String, version: UInt64, spec: ConfigSpec) {
        self.nameOrId = nameOrId
        self.version = version
        self.body = spec
    }
    
    var path: String {
        "configs/\(nameOrId)/update?version=\(version)"
    }    
}
