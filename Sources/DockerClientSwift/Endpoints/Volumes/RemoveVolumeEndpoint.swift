import NIOHTTP1

struct RemoveVolumeEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .DELETE
    
    private let nameOrId: String
    private let force: Bool
    
    init(nameOrId: String, force: Bool) {
        self.nameOrId = nameOrId
        self.force = force
    }
    
    var path: String {
        "volumes/\(nameOrId)?force=\(force)"
    }
}
