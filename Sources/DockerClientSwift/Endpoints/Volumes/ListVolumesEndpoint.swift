import Foundation
import NIOHTTP1

struct ListVolumesEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = ListVolumesResponse
    var method: HTTPMethod = .GET
    
    init(filters: ListVolumesFilter? = nil) {}
    
    var path: String {
        "volumes"
    }
    
    struct ListVolumesResponse: Codable {
        public let Volumes: [Volume]
        public let Warnings: [String]?
    }
    
    // TODO: implement crappy Docker encoding (`{"name":{"myname":true}}`)
    public struct ListVolumesFilter: DockerFilterProtocol {
        public var name: String? = nil
        
        /// Matches volumes based on the presence of a label alone or a label and a value.
        /// Format:  `<key>` or `<key=value>`
        public var label: String? = nil
        
        /// Matches volumes based on their driver.
        public var driver: String? = nil
        
        /// When set to `true`, returns all volumes that are not in use by a container.
        /// When set to `false`, only volumes that are in use by one or more containers are returned
        public var dangling: Bool? = nil
    }
}
