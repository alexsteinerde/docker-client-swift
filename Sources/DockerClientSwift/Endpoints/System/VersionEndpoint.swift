import NIOHTTP1

struct NoBody: Codable {}

struct VersionEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = DockerVersion
    
    var method: HTTPMethod = .GET
    let path: String = "version"
}
