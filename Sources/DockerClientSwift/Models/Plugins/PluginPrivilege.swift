import Foundation

public struct PluginPrivilege: Codable {
    /// The category of privilege
    var name: PrivilegeType
    
    var description: String
    
    var value: [String]
    
    public init(name: PluginPrivilege.PrivilegeType, description: String, value: [String]) {
        self.name = name
        self.description = description
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case description = "Description"
        case value = "Value"
    }
    
    public enum PrivilegeType: String, Codable {
        case mount, network, device, capabilities
    }
}
