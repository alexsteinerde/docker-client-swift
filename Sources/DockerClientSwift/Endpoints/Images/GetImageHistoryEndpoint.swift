import NIOHTTP1

struct GetImageHistoryEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [ImageLayer]
    var method: HTTPMethod = .GET
    
    private var nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "images/\(nameOrId)/history"
    }
}
