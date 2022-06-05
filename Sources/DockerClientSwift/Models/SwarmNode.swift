import Foundation

public struct SwarmNode: Codable {
    
    public let id: String
    
    /// The version number of the object such as node, service, etc. This is needed to avoid conflicting writes.
    /// The client must send the version number along with the modified specification when updating these objects.
    public let version: SwarmVersion
    
    /// Date and time at which the node was added to the Swarm.
    public let createdAt: Date
    
    public let updatedAt: Date
    
    public let spec: SwarmNodeSpec
    
    /// Properties of the Node as reported by the agent.
    public let description: SwarmNodeDescription
    
    /// Provides the current status of the node, as seen by the manager.
    public let status: SwarmNodeStatus
    
    /// Provides the current status of a node's manager component, if the node is a manager
    public let managerStatus: SwarmManagerStatus?
}

public enum SwarmNodeRole: String, Codable {
    case worker, manager
}

public enum SwarmNodeAvailability: String, Codable {
    case active, pause, drain
}

public struct SwarmNodeSpec: Codable {
    public let name: String
    public let labels: [String:String]
    public let role: SwarmNodeRole
    public let availability: SwarmNodeAvailability
}

public struct SwarmNodeDescription: Codable {
    
}

public struct SwarmNodeStatus: Codable {
    
}

public struct SwarmManagerStatus: Codable {
    
}
