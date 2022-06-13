import Foundation
import NIOHTTP1

struct ListVolumesEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = ListVolumesResponse
    var method: HTTPMethod = .GET
    
    init() {}
    
    var path: String {
        "volumes"
    }
    
    struct ListVolumesResponse: Codable {
        public let Volumes: [Volume]
        public let Warnings: [String]?
    }
}
