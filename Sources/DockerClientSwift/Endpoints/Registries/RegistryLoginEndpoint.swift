import NIOHTTP1

struct RegistryLoginEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = RegistryLoginResponse
    typealias Body = RegistryAuth
    var method: HTTPMethod = .POST
    
    init(credentials: RegistryAuth) {
        self.body = credentials
    }
    
    var path: String {
        "auth"
    }
    
    struct RegistryLoginResponse: Codable {
        let Status: String
        let IdentityToken: String?
    }
}
