import NIOHTTP1

struct UpdateServiceEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = NoBody?
    typealias Body = ServiceSpec?
    var method: HTTPMethod = .POST
    
    private let nameOrId: String
    private let version: UInt64
    private let rollback: Bool

    
    
    init(nameOrId: String, version: UInt64, spec: ServiceSpec?, rollback: Bool) {
        self.nameOrId = nameOrId
        self.body = spec
        self.rollback = rollback
        self.version = version
    }
    
    var path: String {
        "services/\(nameOrId)/update?version=\(version)&rollback=\(self.rollback ? "previous" : "")"
    }
}

