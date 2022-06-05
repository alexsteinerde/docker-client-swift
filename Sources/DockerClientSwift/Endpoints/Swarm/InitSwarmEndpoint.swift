import NIOHTTP1
import Foundation

public struct InitSwarmEndpoint: Endpoint {
    var body: Body?
    
    typealias Body = SwarmConfig
    typealias Response = String
    var method: HTTPMethod = .POST
    
    var path: String {
        "swarm/init"
    }
 
    init(config: SwarmConfig) {
        self.body = config
    }
}
