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
        public let manager: String
        public let worker: String
        
        enum CodingKeys: String, CodingKey {
            case manager = "Manager"
            case worker = "Worker"
        }
    }
    
    public struct SwarmTLSInfo: Codable {
        public let CertIssuerPublicKey: String
        public let CertIssuerSubject: String
        public let TrustRoot: String
    }
    
    public struct SwarmResponse: Codable {
        let id: String
        
        let createdAt: String
        let updatedAt: String
        
        /// DataPathPort specifies the data path port number for data traffic. Acceptable port range is 1024 to 49151.
        /// If no port is set or is set to 0, the default port (4789) is used.
        let dataPathPort: UInt16
        
        let defaultAddrPool: [String]
        
        let joinTokens: SwarmJoinTokens
        
        /// Whether there is currently a root CA rotation in progress for the swarm
        let rootRotationInProgress: Bool
        
        let spec: SwarmSpec
        
        /// SubnetSize specifies the subnet size of the networks created from the default subnet pool.
        let subnetSize: UInt8
        
        let tlsInfo: SwarmTLSInfo
        
        let version: SwarmResponseVersion
        
        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case createdAt = "CreatedAt"
            case updatedAt = "UpdatedAt"
            case dataPathPort = "DataPathPort"
            case defaultAddrPool = "DefaultAddrPool"
            case joinTokens = "JoinTokens"
            case rootRotationInProgress = "RootRotationInProgress"
            case spec = "Spec"
            case subnetSize = "SubnetSize"
            case tlsInfo = "TLSInfo"
            case version = "Version"
        }
    }
}
