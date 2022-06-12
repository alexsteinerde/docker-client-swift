import NIOHTTP1

struct UpdateContainerEndpoint: Endpoint {
    var body: ContainerUpdate?
    
    typealias Response = NoBody
    typealias Body = ContainerUpdate
    var method: HTTPMethod = .POST
    
    private let nameOrId: String
    
    init(nameOrId: String, spec: ContainerUpdate) {
        self.nameOrId = nameOrId
        self.body = spec
    }
    
    var path: String {
        "containers/\(nameOrId)/update"
    }
}
