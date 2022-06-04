import NIOHTTP1

struct PingEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = String
    
    var method: HTTPMethod = .GET
    let path: String = "_ping"
}
