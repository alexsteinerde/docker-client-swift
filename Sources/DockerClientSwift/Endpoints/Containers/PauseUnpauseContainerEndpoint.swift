import NIOHTTP1

struct PauseUnpauseContainerEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .POST
    
    private let nameOrId: String
    // if `false`, will pause
    private let unpause: Bool
    
    init(nameOrId: String, unpause: Bool) {
        self.nameOrId = nameOrId
        self.unpause = unpause
    }
    
    var path: String {
        "containers/\(nameOrId)/\(unpause ? "unpause" : "pause")"
    }
}
