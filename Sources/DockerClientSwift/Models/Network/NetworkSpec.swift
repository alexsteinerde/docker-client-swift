import Foundation

public struct NetworkSpec: Codable {
    /// The network's name.
    public var name: String
    
    /// Check for networks with duplicate names.
    /// Since Network is primarily keyed based on a random ID and not on the name, and network name is strictly a user-friendly alias to the network which is uniquely identified using ID, there is no guaranteed way to check for duplicates.
    /// Provides a best effort checking of any networks which has the same name but it is not guaranteed to catch all name collisions.
    public var checkDuplicate: Bool?
    
    /// Name of the network driver plugin to use.
    public var driver: String = "bridge"
    
    /// Restrict external access to the network.
    public var `internal`: Bool?
    
    /// Globally scoped network is manually attachable by regular containers from workers in swarm mode.
    public var attachable: Bool?
    
    /// Ingress network is the network which provides the routing-mesh in swarm mode.
    public var ingress: Bool?
    
    public var ipam: IPAM
    
    /// Enable IPv6 on the network.
    public var enableIPv6: Bool?
        
    /// Network specific options to be used by the drivers.
    public var options: [String:String]?
    
    /// User-defined key/value metadata.
    public var labels: [String:String]?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case checkDuplicate = "CheckDuplicate"
        case driver = "Driver"
        case `internal` = "Internal"
        case attachable = "Attachable"
        case ingress = "Ingress"
        case ipam = "IPAM"
        case enableIPv6 = "EnableIPv6"
        case options = "Options"
        case labels = "Labeels"
    }
}
