import NIOHTTP1

struct UpdateSecretEndpoint: Endpoint {
    typealias Response = NoBody
    typealias Body = SecretSpec
    var method: HTTPMethod = .POST
    
    var body: Body?
    
    private let nameOrId: String
    private let version: UInt64
    
    init(nameOrId: String, version: UInt64, spec: SecretSpec) {
        self.nameOrId = nameOrId
        self.version = version
        self.body = spec
    }
    
    var path: String {
        "secrets/\(nameOrId)/update?version=\(version)"
    }
}
