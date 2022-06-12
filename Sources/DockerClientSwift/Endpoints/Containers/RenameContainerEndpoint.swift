import NIOHTTP1

struct RenameContainerEndpoint: Endpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .POST
    
    private let containerId: String
    private let newName: String
    
    init(containerId: String, newName: String) {
        self.containerId = containerId
        self.newName = newName
    }
    
    var path: String {
        "containers/\(containerId)/rename?name=\(newName)"
    }
}
