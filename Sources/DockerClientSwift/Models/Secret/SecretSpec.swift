import Foundation

public struct SecretSpec: Encodable {
    /// User-defined name of the secret.
    public var name: String
    
    /// User-defined key/value metadata.
    public var labels: [String:String] = [:]
    
    /// Value to store as secret.
    /// NOTE: this field is **not** set when listing or inspecting a secret.
    public var data: Data
    
    /// Secrets driver configuration
    public var driver: DriverConfig?
    
    /// Template driver configuration
    public var templating: DriverConfig?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case labels = "Labels"
        case data = "Data"
        case driver = "Driver"
        case templating = "Templating"
    }
    
    /// Create a new `SecretSpec` containing a `String` value
    public init(name: String, value: String, labels: [String:String] = [:], driver: DriverConfig? = nil, templating: DriverConfig? = nil) {
        self.name = name
        self.data = value.data(using: .utf8)!
        self.labels = labels
        self.driver = driver
        self.templating = templating
    }
    
    /// Create a new `SecretSpec` containing raw `Data`
    public init(name: String, data: Data, labels: [String:String] = [:], driver: DriverConfig? = nil, templating: DriverConfig? = nil) {
        self.name = name
        self.data = data
        self.labels = labels
        self.driver = driver
        self.templating = templating
    }
}

extension SecretSpec: Decodable {
    /// Custom decoding here since Secret Inspect doesn't return the `data field.`
    public init(from decoder: Swift.Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.labels = try container.decode([String:String].self, forKey: .labels)
        self.driver = try container.decodeIfPresent(DriverConfig.self, forKey: .driver)
        self.templating = try container.decodeIfPresent(DriverConfig.self, forKey: .templating)
        self.data = .init()
    }
}
