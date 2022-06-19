import NIOHTTP1

struct DisconnectContainerEndpoint: Endpoint {
    typealias Body = DisconnectContainerRequest
    
    typealias Response = NoBody?
    var method: HTTPMethod = .POST
    
    private let nameOrId: String
    
    var body: Body?
    
    init(nameOrId: String, containerNameOrId: String, force: Bool) {
        self.nameOrId = nameOrId
        self.body = .init(Container: containerNameOrId, Force: force)
    }
    
    var path: String {
        "networks/\(nameOrId)/disconnect"
    }
    
    struct DisconnectContainerRequest: Codable {
        let Container: String
        let Force: Bool
    }
}
