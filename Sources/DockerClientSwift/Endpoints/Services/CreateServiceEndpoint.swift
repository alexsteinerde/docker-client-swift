import NIOHTTP1


struct CreateServiceEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = CreateServiceResponse
    typealias Body = ServiceSpec
    var method: HTTPMethod = .POST
        
    init(spec: ServiceSpec) {
        self.body = spec
    }
    
    var path: String {
        "services/create"
    }
    
    struct CreateServiceResponse: Codable {
        let ID: String
    }
}
