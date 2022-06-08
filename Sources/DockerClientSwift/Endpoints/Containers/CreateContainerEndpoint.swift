import NIOHTTP1

struct CreateContainerEndpoint: Endpoint {
    var body: CreateContainerBody?
    
    typealias Response = CreateContainerResponse
    typealias Body = CreateContainerBody
    var method: HTTPMethod = .POST
    
    private let imageName: String
    private let commands: [String]?
    
    init(imageName: String, commands: [String]?=nil) {
        self.imageName = imageName
        self.commands = commands
        self.body = .init(Image: imageName, Cmd: commands)
    }
    
    var path: String {
        "containers/create"
    }

    struct CreateContainerBody: Codable {
        let Image: String
        let Cmd: [String]?
    }
    
    struct CreateContainerResponse: Codable {
        let Id: String
    }
}

struct CreateContainerEndpoint2: Endpoint {
    typealias Response = CreateContainerResponse
    typealias Body = ContainerCreate
    var method: HTTPMethod = .POST
    
    var body: ContainerCreate?
    private let name: String?
    
    init(name: String? = nil, spec: ContainerCreate) {
        self.name = name
        self.body = spec
    }
    
    var path: String {
        "containers/create\(name != nil ? "?name=\(name!)" : "")"
    }

    struct CreateContainerResponse: Codable {
        let Id: String
        let Warnings: [String]
    }
}
