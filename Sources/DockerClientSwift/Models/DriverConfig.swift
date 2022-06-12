import Foundation

//// Specific the log driver and its options for a Swarm (globally) or for a Service.
public struct DriverConfig: Codable {
    /// The log driver to use as a default for new tasks.
    public let name: String?
    
    /// Driver-specific options for the selectd log driver, specified as key/value pairs.
    public let options: [String:String]?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case options = "Options"
    }
}
