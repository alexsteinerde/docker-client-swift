import NIOHTTP1

struct InstallPluginEndpoint: Endpoint {
    typealias Response = NoBody
    typealias Body = [PluginPrivilege]
    var method: HTTPMethod = .POST
    
    var path: String {
        "plugins/pull?remote=\(remote)\(self.alias != nil ? "&name=\(self.alias!)" : "")"
    }
    var headers: HTTPHeaders? = nil
    var body: Body?
    
    private let remote: String
    private let alias: String?
    private let credentials: RegistryAuth?
    
    init(remote: String, alias: String?, privileges: [PluginPrivilege]?, credentials: RegistryAuth?) {
        self.body = privileges ?? []
        self.remote = remote
        self.alias = alias
        self.credentials = credentials
        if let credentials = credentials, let token = credentials.token {
            self.headers = .init([("X-Registry-Auth", token)])
        }
    }
}
