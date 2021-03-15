import NIOHTTP1

struct CreateServiceEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = CreateServiceResponse
    typealias Body = Service.UpdateServiceBody
    var method: HTTPMethod = .POST
    
    private let name: String
    private let image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
        self.body = Service.UpdateServiceBody(Name: name, TaskTemplate: .init(ContainerSpec: .init(Image: image)))
    }
    
    var path: String {
        "services/create"
    }

    struct CreateServiceResponse: Codable {
        let ID: String
    }
}
