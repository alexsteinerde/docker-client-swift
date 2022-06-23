import NIOHTTP1

struct UpgradePluginEndpoint: Endpoint {
    typealias Response = NoBody
    typealias Body = [PluginPrivilege]
    var method: HTTPMethod = .POST
    
    var path: String {
        "plugins/\(name)/upgrade?remote=\(remote)"
    }
    var headers: HTTPHeaders? = nil
    var body: Body?
    
    private let name: String
    private let remote: String
    private let credentials: RegistryAuth?
    
    init(name: String, remote: String, privileges: [PluginPrivilege]?, credentials: RegistryAuth?) {
        self.body = privileges ?? []
        self.name = name
        self.remote = remote
        self.credentials = credentials
        if let credentials = credentials, let token = credentials.token {
            self.headers = .init([("X-Registry-Auth", token)])
        }
    }
}
