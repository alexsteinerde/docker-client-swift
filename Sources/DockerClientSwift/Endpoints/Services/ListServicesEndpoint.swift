import Foundation
import NIOHTTP1

struct ListServicesEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = [Service.ServiceResponse]
    var method: HTTPMethod = .GET
    
    init() {
    }
    
    var path: String {
        "services"
    }
}
