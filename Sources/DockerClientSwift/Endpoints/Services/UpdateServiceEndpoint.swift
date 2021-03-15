import NIOHTTP1

struct UpdateServiceEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = NoBody?
    typealias Body = Service.UpdateServiceBody
    var method: HTTPMethod = .POST
    
    private let nameOrId: String
    private let version: Int
    private let image: String?
    private let name: String
    
    init(nameOrId: String, name: String, version: Int, image: String?) {
        self.nameOrId = nameOrId
        self.name = name
        self.version = version
        self.image = image
        
        self.body = .init(Name: name, TaskTemplate: .init(ContainerSpec: .init(Image: image)))
    }
    
    var path: String {
        "services/\(nameOrId)/update?version=\(version)"
    }
}

extension Service {
    struct UpdateServiceBody: Codable {
        let Name: String
        let TaskTemplate: TaskTemplateBody
        struct TaskTemplateBody: Codable {
            let ContainerSpec: ContainerSpecBody
        }
        
        struct ContainerSpecBody: Codable {
            let Image: String?
        }
    }
}
