import Foundation

public struct SwarmOrchestration: Codable {
    /// The number of historic tasks to keep per instance or node. If negative, never remove completed or failed tasks.
    public let TaskHistoryRetentionLimit: Int64
}

public struct SwarmDispatcher: Codable {
    /// The delay for an agent to send a heartbeat to the dispatcher.
    public let HeartbeatPeriod: Int64
}

public struct SwarmEncryptionConfig: Codable {
    /// If set, generate a key and use it to lock data stored on the managers.
    public let AutoLockManagers: Bool
}

public struct SwarmLogDriver: Codable {
    /// The log driver to use as a default for new tasks.
    public let Name: String?
    
    /// Driver-specific options for the selectd log driver, specified as key/value pairs.
    public let Options: [String:String]?
}

public struct SwarmTaskDefaults: Codable {
    /// The log driver to use for tasks created in the orchestrator if unspecified by a service.
    /// Updating this value only affects new tasks. Existing tasks continue to use their previously configured log driver until recreated.
    public let LogDriver: SwarmLogDriver?
}

public struct SwarmExternalCA: Codable {
    /// Protocol for communication with the external CA (currently only `cfssl` is supported).
    public var `Protocol`: String? = "cfssl"
    
    /// URL where certificate signing requests should be sent.
    public let URL: String?
    
    /// An object with key/value pairs that are interpreted as protocol-specific options for the external CA driver.
    public let Options: [String:String]?
}

public struct SwarmCAConfig: Codable {
    
    /// Configuration for forwarding signing requests to an external certificate authority.
    public let ExternalCAs: [SwarmExternalCA]?
    
    /// An integer whose purpose is to force swarm to generate a new signing CA certificate and key, if none have been specified in `SigningCACert` and `SigningCAKey`
    public let ForceRotate: UInt64?
    
    /// The duration node certificates are issued for.
    public let NodeCertExpiry: UInt64?
    
    /// The desired signing CA certificate for all swarm node TLS leaf certificates, in PEM format.
    public let SigningCACert: String?
    
    /// The desired signing CA key for all swarm node TLS leaf certificates, in PEM format.
    public let SigningCAKey: String?
    
}

public struct SwarmSpec: Codable {
    /// CA configuration.
    public var CAConfig: SwarmCAConfig? = nil
    
    /// Dispatcher configuration (Swarm nodes heartbeat).
    public var Dispatcher: SwarmDispatcher? = nil
    
    /// Parameters related to encryption-at-rest.
    public var EncryptionConfig: SwarmEncryptionConfig? = nil
    
    /// Name of the swarm. Must be `default`and cannot be updated.
    public let Name: String = "default"
    
    /// User-defined key/value metadata.
    /// Can only be set during Swarm init, cannot be updated.
    public var Labels: [String:String]?
    
    /// Orchestration configuration.
    public var Orchestration: SwarmOrchestration? = nil
    
    // public let Raft
    
    /// Defaults for creating tasks in this cluster.
    public var TaskDefaults: SwarmTaskDefaults? = nil
}

/// Representation of a Swarm init.
public struct SwarmCreate : Codable {
    /// Externally reachable address advertised to other nodes.
    /// This can either be an address/port combination in the form `192.168.1.1:4567`, or an interface followed by a port number, like `eth0:4567`.
    /// If the port number is omitted, the port number from the listen address is used. If `AdvertiseAddr` is not specified, it will be automatically detected when possible.
    public var AdvertiseAddr: String? = nil
    
    /// Address or interface to use for data path traffic (format: `<ip|interface>`), for example, `192.168.1.1`, or an interface, like `eth0`.
    /// If `DataPathAddr` is unspecified, the same address as `AdvertiseAddr` is used.
    /// The `DataPathAddr` specifies the address that global scope network drivers will publish towards other nodes in order to reach the containers running on this node.
    /// Using this parameter it is possible to separate the container data traffic from the management traffic of the cluster.
    public var DataPathAddr: String? = nil
    
    /// DataPathPort specifies the data path port number for data traffic. Acceptable port range is 1024 to 49151.
    /// If no port is set or is set to 0, default port 4789 will be used.
    public var DataPathPort: UInt16 = 0
    
    /// Default Address Pool specifies default subnet pools for global scope networks.
    public var DefaultAddrPool: [String]? = nil
    
    /// Force creation of a new swarm.
    public var ForceNewCluster: Bool = false
    
    /// Listen address used for inter-manager communication, as well as determining the networking interface used for the VXLAN Tunnel Endpoint (VTEP).
    /// This can either be an address/port combination in the form `192.168.1.1:4567`, or an interface followed by a port number, like `eth0:4567`.
    /// If the port number is omitted, the default swarm listening port is used.
    public var ListenAddr: String = "0.0.0.0"
    
    /// User modifiable swarm configuration.
    public var Spec: SwarmSpec = .init()
    
    /// SubnetSize specifies the subnet size of the networks created from the default subnet pool.
    public var SubnetSize: UInt8? = nil
    
}
