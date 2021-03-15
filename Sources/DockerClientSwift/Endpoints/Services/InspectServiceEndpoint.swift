import Foundation
import NIOHTTP1

struct InspectServiceEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = Service.ServiceResponse
    var method: HTTPMethod = .GET
    
    
    private let nameOrId: String
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    var path: String {
        "services/\(nameOrId)"
    }
}

internal extension Service {
    struct ServiceResponse: Codable {
        let ID: String
        let Version: ServiceVersionResponse
        let CreatedAt: String
        let UpdatedAt: String
        let Spec: ServiceSpecResponse
        
        struct ServiceVersionResponse: Codable {
            let Index: Int
        }
        
        struct ServiceSpecResponse: Codable {
            let Name: String
            let TaskTemplate: TaskTemplateResponse
        }
        
        struct TaskTemplateResponse: Codable {
            let ContainerSpec: ContainerSpecResponse
        }
        
        struct ContainerSpecResponse: Codable {
            let Image: String
        }
    }
}
