import NIOHTTP1

struct ListImagesEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [ImageSummary]
    var method: HTTPMethod = .GET
    
    private var all: Bool
    
    init(all: Bool) {
        self.all = all
    }
    
    var path: String {
        "images/json?all=\(all)"
    }
}
