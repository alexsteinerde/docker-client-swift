import Foundation

// MARK: - Orchestration
public struct SwarmOrchestration: Codable {
    /// The number of historic tasks to keep per instance or node. If negative, never remove completed or failed tasks.
    public let taskHistoryRetentionLimit: Int64
    
    enum CodingKeys: String, CodingKey {
        case taskHistoryRetentionLimit = "TaskHistoryRetentionLimit"
    }
}

// MARK: - SwarmDispatcher
public struct SwarmDispatcher: Codable {
    /// The delay for an agent to send a heartbeat to the dispatcher.
    public let heartbeatPeriod: Int64
    
    enum CodingKeys: String, CodingKey {
        case heartbeatPeriod = "HeartbeatPeriod"
    }
}

// MARK: - SwarmEncryptionConfig
public struct SwarmEncryptionConfig: Codable {
    /// If set, generate a key and use it to lock data stored on the managers.
    public let autoLockManagers: Bool
    
    enum CodingKeys: String, CodingKey {
        case autoLockManagers = "AutoLockManagers"
    }
}

public struct SwarmTaskDefaults: Codable {
    /// The log driver to use for tasks created in the orchestrator if unspecified by a service.
    /// Updating this value only affects new tasks. Existing tasks continue to use their previously configured log driver until recreated.
    public let logDriver: DriverConfig?
    
    enum CodingKeys: String, CodingKey {
        case logDriver = "LogDriver"
    }
}

// MARK: - ExternalCA
public struct SwarmExternalCA: Codable {
    /// Protocol for communication with the external CA (currently only `cfssl` is supported).
    public var `protocol`: String? = "cfssl"
    
    /// URL where certificate signing requests should be sent.
    public let url: String?
    
    /// An object with key/value pairs that are interpreted as protocol-specific options for the external CA driver.
    public let options: [String:String]?
    
    public let caCert: String?
    
    enum CodingKeys: String, CodingKey {
        case `protocol` = "Protocol"
        case url = "URL"
        case options = "Options"
        case caCert = "CACert"
    }
}

// MARK: - SwarmCAConfig
public struct SwarmCAConfig: Codable {
    
    /// Configuration for forwarding signing requests to an external certificate authority.
    public let externalCAs: [SwarmExternalCA]?
    
    /// An integer whose purpose is to force swarm to generate a new signing CA certificate and key, if none have been specified in `SigningCACert` and `SigningCAKey`
    public let forceRotate: UInt64?
    
    /// The duration node certificates are issued for.
    public let nodeCertExpiry: UInt64?
    
    /// The desired signing CA certificate for all swarm node TLS leaf certificates, in PEM format.
    public let signingCACert: String?
    
    /// The desired signing CA key for all swarm node TLS leaf certificates, in PEM format.
    public let signingCAKey: String?
    
    enum CodingKeys: String, CodingKey {
        case nodeCertExpiry = "NodeCertExpiry"
        case externalCAs = "ExternalCAs"
        case signingCACert = "SigningCACert"
        case signingCAKey = "SigningCAKey"
        case forceRotate = "ForceRotate"
    }
    
}

// MARK: - Raft
public struct Raft: Codable {
    public let snapshotInterval, keepOldSnapshots, logEntriesForSlowFollowers, electionTick: Int
    public let heartbeatTick: Int
    
    enum CodingKeys: String, CodingKey {
        case snapshotInterval = "SnapshotInterval"
        case keepOldSnapshots = "KeepOldSnapshots"
        case logEntriesForSlowFollowers = "LogEntriesForSlowFollowers"
        case electionTick = "ElectionTick"
        case heartbeatTick = "HeartbeatTick"
    }
}

// MARK: - SwarmSpec
public struct SwarmSpec: Codable {
    /// CA configuration.
    public var caConfig: SwarmCAConfig? = nil
    
    /// Dispatcher configuration (Swarm nodes heartbeat).
    public var dispatcher: SwarmDispatcher? = nil
    
    /// Parameters related to encryption-at-rest.
    public var encryptionConfig: SwarmEncryptionConfig? = nil
    
    /// Name of the swarm. Must be `default`and cannot be updated.
    private(set) public var name: String = "default"
    
    /// User-defined key/value metadata.
    /// Can only be set during Swarm init, cannot be updated.
    public var labels: [String:String]?
    
    /// Orchestration configuration.
    public var orchestration: SwarmOrchestration? = nil
    
    public var raft: Raft?
    
    /// Defaults for creating tasks in this cluster.
    public var taskDefaults: SwarmTaskDefaults? = nil
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case labels = "Labels"
        case orchestration = "Orchestration"
        case raft = "Raft"
        case dispatcher = "Dispatcher"
        case caConfig = "CAConfig"
        case encryptionConfig = "EncryptionConfig"
        case taskDefaults = "TaskDefaults"
    }
    
    public init(){}
    
    public init(caConfig: SwarmCAConfig? = nil, dispatcher: SwarmDispatcher? = nil, encryptionConfig: SwarmEncryptionConfig? = nil, name: String = "default", labels: [String : String]? = nil, orchestration: SwarmOrchestration? = nil, raft: Raft? = nil, taskDefaults: SwarmTaskDefaults? = nil) {
        self.caConfig = caConfig
        self.dispatcher = dispatcher
        self.encryptionConfig = encryptionConfig
        self.name = name
        self.labels = labels
        self.orchestration = orchestration
        self.raft = raft
        self.taskDefaults = taskDefaults
    }
    
}

// MARK: - SwarmConfig
/// Representation of a Swarm init configuration.
public struct SwarmConfig : Codable {
    /// Externally reachable address advertised to other nodes.
    /// This can either be an address/port combination in the form `192.168.1.1:4567`, or an interface followed by a port number, like `eth0:4567`.
    /// If the port number is omitted, the port number from the listen address is used. If `AdvertiseAddr` is not specified, it will be automatically detected when possible.
    public var advertiseAddr: String? = nil
    
    /// Address or interface to use for data path traffic (format: `<ip|interface>`), for example, `192.168.1.1`, or an interface, like `eth0`.
    /// If `DataPathAddr` is unspecified, the same address as `AdvertiseAddr` is used.
    /// The `DataPathAddr` specifies the address that global scope network drivers will publish towards other nodes in order to reach the containers running on this node.
    /// Using this parameter it is possible to separate the container data traffic from the management traffic of the cluster.
    public var dataPathAddr: String? = nil
    
    /// DataPathPort specifies the data path port number for data traffic. Acceptable port range is 1024 to 49151.
    /// If no port is set or is set to 0, default port 4789 will be used.
    public var dataPathPort: UInt16 = 0
    
    /// Default Address Pool specifies default subnet pools for global scope networks.
    public var defaultAddrPool: [String]? = nil
    
    /// Force creation of a new swarm.
    public var forceNewCluster: Bool = false
    
    /// Listen address used for inter-manager communication, as well as determining the networking interface used for the VXLAN Tunnel Endpoint (VTEP).
    /// This can either be an address/port combination in the form `192.168.1.1:4567`, or an interface followed by a port number, like `eth0:4567`.
    /// If the port number is omitted, the default swarm listening port is used.
    public var listenAddr: String = "0.0.0.0"
    
    /// User modifiable swarm configuration.
    public var spec: SwarmSpec = .init()
    
    /// SubnetSize specifies the subnet size of the networks created from the default subnet pool.
    public var subnetSize: UInt8? = nil
    
    enum CodingKeys: String, CodingKey {
        case advertiseAddr = "AdvertiseAddr"
        case dataPathAddr = "DataPathAddr"
        case dataPathPort = "DataPathPort"
        case defaultAddrPool = "DefaultAddrPool"
        case forceNewCluster = "ForceNewCluster"
        case listenAddr = "ListenAddr"
        case spec = "Spec"
        case subnetSize = "SubnetSize"
    }
    
    public init() {}
    
    public init(advertiseAddr: String? = nil, dataPathAddr: String? = nil, dataPathPort: UInt16 = 0, defaultAddrPool: [String]? = nil, forceNewCluster: Bool = false, listenAddr: String = "0.0.0.0", spec: SwarmSpec = .init(), subnetSize: UInt8? = nil) {
        self.advertiseAddr = advertiseAddr
        self.dataPathAddr = dataPathAddr
        self.dataPathPort = dataPathPort
        self.defaultAddrPool = defaultAddrPool
        self.forceNewCluster = forceNewCluster
        self.listenAddr = listenAddr
        self.spec = spec
        self.subnetSize = subnetSize
    }
}
