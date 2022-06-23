import NIOHTTP1

struct CreateSecretEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = CreateSecretResponse
    typealias Body = SecretSpec
    var method: HTTPMethod = .POST
    
    var path: String {
        "secrets/create"
    }
    
    init(spec: SecretSpec) {
        self.body = spec
    }
    
    struct CreateSecretResponse: Codable {
        let ID: String
    }
}
