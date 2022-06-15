import NIOHTTP1

struct CreateSecretEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = CreateSecretResponse
    typealias Body = SecretSpec
    var method: HTTPMethod = .POST
    
    init(spec: SecretSpec) {
        self.body = spec
    }
    
    var path: String {
        "secrets/create"
    }
    
    struct CreateSecretResponse: Codable {
        let ID: String
    }
}
