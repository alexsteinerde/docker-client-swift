import Foundation

public struct ConfigSpec: Codable {
    /// User-defined name of the config.
    public var name: String
    
    /// User-defined key/value metadata.
    public var labels: [String:String] = [:]
    
    /// Base64-url-safe-encoded (RFC 4648) config data.
    public var data: Data
    
    /// Template driver configuration
    public var templating: DriverConfig?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case labels = "Labels"
        case data = "Data"
        case templating = "Templating"
    }
    
    /// Create a new `ConfigSpec` containing a `String` value
    public init(name: String, data: String, labels: [String:String] = [:], templating: DriverConfig? = nil) {
        self.name = name
        self.data = data.data(using: .utf8)!
        self.labels = labels
        self.templating = templating
    }
    
    /// Create a new `ConfigSpec` containing raw `Data`
    public init(name: String, data: Data, labels: [String:String] = [:], templating: DriverConfig? = nil) {
        self.name = name
        self.data = data
        self.labels = labels
        self.templating = templating
    }
}
