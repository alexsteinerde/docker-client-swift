import NIOHTTP1

struct CreateContainerEndpoint: Endpoint {
    var body: CreateContainerBody?
    
    typealias Response = CreateContainerResponse
    typealias Body = CreateContainerBody
    var method: HTTPMethod = .POST
    
    private let imageName: String
    private let commands: [String]?
    
    init(imageName: String, commands: [String]?=nil, exposedPorts: [String: CreateContainerBody.Empty]?=nil, hostConfig: CreateContainerBody.HostConfig?=nil) {
        self.imageName = imageName
        self.commands = commands
        self.body = .init(Image: imageName, Cmd: commands, ExposedPorts: exposedPorts, HostConfig: hostConfig)
    }
    
    var path: String {
        "containers/create"
    }

    struct CreateContainerBody: Codable {
        let Image: String
        let Cmd: [String]?
        let ExposedPorts: [String: Empty]?
        let HostConfig: HostConfig?
        
        struct Empty: Codable {}
        
        struct HostConfig: Codable {
            let PortBindings: [String: [PortBinding]?]
            
            struct PortBinding: Codable {
                let HostIp: String?
                let HostPort: String?
            }
        }
    }
    
    struct CreateContainerResponse: Codable {
        let Id: String
    }
}
