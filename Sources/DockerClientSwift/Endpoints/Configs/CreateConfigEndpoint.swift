import NIOHTTP1

struct CreateConfigEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = CreateConfigResponse
    typealias Body = ConfigSpec
    var method: HTTPMethod = .POST
    
    init(spec: ConfigSpec) {
        self.body = spec
    }
    
    var path: String {
        "configs/create"
    }
    
    struct CreateConfigResponse: Codable {
        let ID: String
    }
}
