import NIOHTTP1
import Foundation

struct PruneImagesEndpoint: Endpoint {
    var body: Body?
    
    typealias Response = PruneImagesResponse
    typealias Body = NoBody
    var method: HTTPMethod = .POST

    private var dangling: Bool
    
    /// Init
    /// - Parameter dangling: When set to `true`, prune only unused *and* untagged images. When set to `false`, all unused images are prune.
    init(dangling: Bool=true) {
        self.dangling = dangling
    }
    
    var path: String {
        "images/prune?filters={\"dangling\": [\"false\"]}"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }

    struct PruneImagesResponse: Codable {
        let ImagesDeleted: [PrunedImageResponse]?
        let SpaceReclaimed: UInt64
        
        struct PrunedImageResponse: Codable {
            let Deleted: String?
            let Untagged: String?
        }
    }
}

