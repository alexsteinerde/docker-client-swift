import Foundation
import NIOHTTP1

struct InspectVolumeEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = Volume
    var method: HTTPMethod = .GET
    
    private let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "volumes/\(nameOrId)"
    }
}
