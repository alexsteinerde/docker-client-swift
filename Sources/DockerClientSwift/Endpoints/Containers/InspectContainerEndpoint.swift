import NIOHTTP1

struct InspectContainerEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = ContainerResponse
    var method: HTTPMethod = .GET
    
    let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "containers/\(nameOrId)/json"
    }
    
    struct ContainerResponse: Codable {
        let Id: String
        let Name: String
        let Config: ConfigResponse
        let Image: String
        let Created: String
        let State: StateResponse
        let NetworkSettings: NetworkSettings
        // TODO: Add additional fields
        
        struct StateResponse: Codable {
            var Error: String
            var Status: String
        }
        
        struct ConfigResponse: Codable {
            let Cmd: [String]?
        }
        
        struct NetworkSettings: Codable {
            let Ports: [String: [PortBinding]?]
            
            struct PortBinding: Codable {
                let HostIp: String
                let HostPort: String
            }
        }
    }
}
