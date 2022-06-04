import NIOHTTP1
import Foundation

public struct InspectSwarmEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = SwarmResponse
    var method: HTTPMethod = .GET
    
    var path: String {
        "swarm"
    }
    
    public struct SwarmResponseVersion: Codable {
        let Index: UInt64
    }
    
    public struct SwarmJoinTokens: Codable {
        public let Manager: String
        public let Worker: String
    }
    
    public struct SwarmTLSInfo: Codable {
        public let CertIssuerPublicKey: String
        public let CertIssuerSubject: String
        public let TrustRoot: String
    }
    
    public struct SwarmResponse: Codable {
        let ID: String
        
        let CreatedAt: String
        let UpdatedAt: String
        
        /// DataPathPort specifies the data path port number for data traffic. Acceptable port range is 1024 to 49151.
        /// If no port is set or is set to 0, the default port (4789) is used.
        let DataPathPort: UInt16
        
        let DefaultAddrPool: [String]
        
        let JoinTokens: SwarmJoinTokens
        
        /// Whether there is currently a root CA rotation in progress for the swarm
        let RootRotationInProgress: Bool
        
        let Spec: SwarmSpec
        
        /// SubnetSize specifies the subnet size of the networks created from the default subnet pool.
        let SubnetSize: UInt8
        
        let TLSInfo: SwarmTLSInfo
        
        let Version: SwarmResponseVersion
    }
}
