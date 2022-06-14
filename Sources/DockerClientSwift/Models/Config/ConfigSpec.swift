import Foundation

public struct ConfigSpec: Codable {
    /// User-defined name of the config.
    public var name: String
    
    /// User-defined key/value metadata.
    public var labels: [String:String]
    
    /// Base64-url-safe-encoded (RFC 4648) config data.
    public var data: String
    
    public var templating: DriverConfig?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case labels = "Labels"
        case data = "Data"
        case templating = "Templating"
    }
}
