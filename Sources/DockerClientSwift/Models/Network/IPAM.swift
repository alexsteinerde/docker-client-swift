import Foundation

/// IP Addresses Management (IPAM) configuration options
public struct IPAM: Codable {
    /// Name of the IPAM driver to use.
    public var driver: String = "default"
    
    public var config: [IPAMConfig]
    
    /// Driver-specific options
    public var options: [String:String]? = nil
    
    public init(driver: String = "default", config: [IPAM.IPAMConfig], options: [String : String]? = nil) {
        self.driver = driver
        self.config = config
        self.options = options
    }
    
    enum CodingKeys: String, CodingKey {
        case driver = "Driver"
        case config = "Config"
        case options = "Options"
    }
    
    public struct IPAMConfig: Codable {
        public var subnet: String?
        public var ipRange: String?
        public var gateway: String
        public var auxiliaryAddresses: [String:String]? = [:]
        
        enum CodingKeys: String, CodingKey {
            case subnet = "Subnet"
            case ipRange = "IPRange"
            case gateway = "Gateway"
            case auxiliaryAddresses = "AuxiliaryAddresses"
        }
    }
}
