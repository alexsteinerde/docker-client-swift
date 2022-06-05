import Foundation

public struct SwarmNode: Codable {
    
    public let id: String
    
    /// Date and time at which the node was added to the Swarm.
    public let createdAt: Date
    
    public let updatedAt: Date
    
    /// Properties of the Node as reported by the agent.
    public let description: SwarmNodeDescription
    
    /// Provides the current status of a node's manager component, if the node is a manager
    public let managerStatus: SwarmManagerStatus?
    
    public let spec: SwarmNodeSpec
    
    /// Provides the current status of the node, as seen by the manager.
    public let status: SwarmNodeStatus
    
    /// The version number of the object such as node, service, etc. This is needed to avoid conflicting writes.
    /// The client must send the version number along with the modified specification when updating these objects.
    public let version: SwarmVersion
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
        case description = "Description"
        case managerStatus = "ManagerStatus"
        case spec = "Spec"
        case status = "Status"
        case version = "Version"
    }
}

public enum SwarmNodeRole: String, Codable {
    case worker, manager
}

public enum SwarmNodeAvailability: String, Codable {
    case active, pause, drain
}

public struct SwarmNodeDescription: Codable {
    // TODO:
}

public struct SwarmNodeStatus: Codable {
    // TODO:
}

public struct SwarmManagerStatus: Codable {
    // TODO: 
}

public struct SwarmNodeSpec: Codable {
    public var name: String
    public var labels: [String:String]
    public var role: SwarmNodeRole
    public var availability: SwarmNodeAvailability
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case labels = "Labels"
        case role = "Role"
        case availability = "Availability"
    }
}
