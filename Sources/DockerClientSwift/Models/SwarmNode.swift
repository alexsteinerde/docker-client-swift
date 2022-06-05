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


public struct SwarmNodeDescriptionPlatform: Codable {
    /// Architecture represents the hardware architecture (for example, x86_64).
    public let architecture: String
    
    /// OS represents the Operating System (for example, linux or windows).
    public let os: String
    
    enum CodingKeys: String, CodingKey {
        case architecture = "Architecture"
        case os = "OS"
    }
}

public struct SwarmNodeDescriptionResources: Codable {
    
    public let nanoCPUs: UInt64
    
    public let memoryBytes: UInt64
    
    // TODO: implement GenericResources
    
    enum CodingKeys: String, CodingKey {
        case nanoCPUs = "NanoCPUs"
        case memoryBytes = "MemoryBytes"
        // case genericResources = "GenericResources"
    }
}

public struct SwarmNodeDescriptionPlugins: Codable {
    public let type: String
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case name = "Name"
    }
}

public struct SwarmNodeDescriptionEngine: Codable {
    
    public let engineVersion: String
    
    public let labels: [String:String]?
    
    public let plugins: [SwarmNodeDescriptionPlugins]
    
    enum CodingKeys: String, CodingKey {
        case engineVersion = "EngineVersion"
        case labels = "Labels"
        case plugins = "Plugins"
    }
}

public struct SwarmNodeDescription: Codable {
    public let hostname: String
    public let platform: SwarmNodeDescriptionPlatform
    public let resources: SwarmNodeDescriptionResources
    public let engine: SwarmNodeDescriptionEngine
    public let tlsInfo: SwarmTLSInfo
    
    enum CodingKeys: String, CodingKey {
        case hostname = "Hostname"
        case platform = "Platform"
        case resources = "Resources"
        case engine = "Engine"
        case tlsInfo = "TLSInfo"
    }
}

public enum SwarmNodeState: String, Codable {
    case unknown, down, ready, disconnected
}

public struct SwarmNodeStatus: Codable {
    public let state: SwarmNodeState
    public let message: String?
    public let address: String
    
    enum CodingKeys: String, CodingKey {
        case state = "State"
        case message = "Message"
        case address = "Addr"
    }
}

public enum SwarmManagerReachability: String, Codable {
    case unknown, unreachable, reachable
}

public struct SwarmManagerStatus: Codable {
    public let leader: Bool
    public let reachability: SwarmManagerReachability
    public let address: String
    
    enum CodingKeys: String, CodingKey {
        case leader = "Leader"
        case reachability = "Reachability"
        case address = "Addr"
    }
}

public struct SwarmNodeSpec: Codable {
    public var name: String?
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
