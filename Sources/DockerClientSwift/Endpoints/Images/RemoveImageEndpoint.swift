import NIOHTTP1

struct RemoveImageEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .DELETE
    var path: String {
        "images/\(nameOrId)?force=\(force ? "true" : "false")"
    }
    
    private let nameOrId: String
    private let force: Bool
    
    init(nameOrId: String, force: Bool=false) {
        self.nameOrId = nameOrId
        self.force = force
    }
}
