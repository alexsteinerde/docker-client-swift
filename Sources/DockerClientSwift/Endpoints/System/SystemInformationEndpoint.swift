import NIOHTTP1

struct SystemInformationEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = SystemInformation
    
    var method: HTTPMethod = .GET
    let path: String = "info"
}
