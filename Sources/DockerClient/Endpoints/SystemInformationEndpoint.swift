import NIOHTTP1

struct SystemInformationEndpoint: Endpoint {
    typealias Body = NoBody
    
    var method: HTTPMethod = .GET
    let path: String = "info"

    typealias Response = SystemInformationResponse
    
    // MARK: - SystemInformationResponse
    struct SystemInformationResponse: Codable {
        let id: String
        let containers, containersRunning, containersPaused, containersStopped: Int
        let images: Int
        let driver: String
        let driverStatus: [[String]]
        let dockerRootDir: String
        let plugins: Plugins?
        let memoryLimit, swapLimit, kernelMemory, cpuCfsPeriod: Bool
        let cpuCfsQuota, cpuShares, cpuSet, pidsLimit: Bool
        let oomKillDisable, iPv4Forwarding, bridgeNfIptables, bridgeNfIp6Tables: Bool
        let debug: Bool
        let nFd, nGoroutines: Int
        let systemTime, loggingDriver, cgroupDriver, cgroupVersion: String
        let nEventsListener: Int
        let kernelVersion, operatingSystem, osVersion, osType: String
        let architecture: String
        let ncpu, memTotal: Int
        let indexServerAddress: String
        let registryConfig: RegistryConfig
        let genericResources: [GenericResource]?
        let httpProxy: String
        let httpsProxy: String
        let noProxy, name: String
        let labels: [String]
        let experimentalBuild: Bool
        let serverVersion, clusterStore, clusterAdvertise: String?
        let runtimes: Runtimes?
        let defaultRuntime: String
        let swarm: Swarm?
        let liveRestoreEnabled: Bool
        let isolation, initBinary: String
        let containerdCommit, runcCommit, initCommit: Commit
        let securityOptions: [String]
        let productLicense: String
        let defaultAddressPools: [DefaultAddressPool]?
        let warnings: [String]?

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case containers = "Containers"
            case containersRunning = "ContainersRunning"
            case containersPaused = "ContainersPaused"
            case containersStopped = "ContainersStopped"
            case images = "Images"
            case driver = "Driver"
            case driverStatus = "DriverStatus"
            case dockerRootDir = "DockerRootDir"
            case plugins = "Plugins"
            case memoryLimit = "MemoryLimit"
            case swapLimit = "SwapLimit"
            case kernelMemory = "KernelMemory"
            case cpuCfsPeriod = "CpuCfsPeriod"
            case cpuCfsQuota = "CpuCfsQuota"
            case cpuShares = "CPUShares"
            case cpuSet = "CPUSet"
            case pidsLimit = "PidsLimit"
            case oomKillDisable = "OomKillDisable"
            case iPv4Forwarding = "IPv4Forwarding"
            case bridgeNfIptables = "BridgeNfIptables"
            case bridgeNfIp6Tables = "BridgeNfIp6tables"
            case debug = "Debug"
            case nFd = "NFd"
            case nGoroutines = "NGoroutines"
            case systemTime = "SystemTime"
            case loggingDriver = "LoggingDriver"
            case cgroupDriver = "CgroupDriver"
            case cgroupVersion = "CgroupVersion"
            case nEventsListener = "NEventsListener"
            case kernelVersion = "KernelVersion"
            case operatingSystem = "OperatingSystem"
            case osVersion = "OSVersion"
            case osType = "OSType"
            case architecture = "Architecture"
            case ncpu = "NCPU"
            case memTotal = "MemTotal"
            case indexServerAddress = "IndexServerAddress"
            case registryConfig = "RegistryConfig"
            case genericResources = "GenericResources"
            case httpProxy = "HttpProxy"
            case httpsProxy = "HttpsProxy"
            case noProxy = "NoProxy"
            case name = "Name"
            case labels = "Labels"
            case experimentalBuild = "ExperimentalBuild"
            case serverVersion = "ServerVersion"
            case clusterStore = "ClusterStore"
            case clusterAdvertise = "ClusterAdvertise"
            case runtimes = "Runtimes"
            case defaultRuntime = "DefaultRuntime"
            case swarm = "Swarm"
            case liveRestoreEnabled = "LiveRestoreEnabled"
            case isolation = "Isolation"
            case initBinary = "InitBinary"
            case containerdCommit = "ContainerdCommit"
            case runcCommit = "RuncCommit"
            case initCommit = "InitCommit"
            case securityOptions = "SecurityOptions"
            case productLicense = "ProductLicense"
            case defaultAddressPools = "DefaultAddressPools"
            case warnings = "Warnings"
        }
    }

    // MARK: - Commit
    struct Commit: Codable {
        let id, expected: String

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case expected = "Expected"
        }
    }

    // MARK: - DefaultAddressPool
    struct DefaultAddressPool: Codable {
        let base, size: String

        enum CodingKeys: String, CodingKey {
            case base = "Base"
            case size = "Size"
        }
    }

    // MARK: - GenericResource
    struct GenericResource: Codable {
        let discreteResourceSpec: DiscreteResourceSpec?
        let namedResourceSpec: NamedResourceSpec?

        enum CodingKeys: String, CodingKey {
            case discreteResourceSpec = "DiscreteResourceSpec"
            case namedResourceSpec = "NamedResourceSpec"
        }
    }

    // MARK: - DiscreteResourceSpec
    struct DiscreteResourceSpec: Codable {
        let kind: String
        let value: Int

        enum CodingKeys: String, CodingKey {
            case kind = "Kind"
            case value = "Value"
        }
    }

    // MARK: - NamedResourceSpec
    struct NamedResourceSpec: Codable {
        let kind, value: String

        enum CodingKeys: String, CodingKey {
            case kind = "Kind"
            case value = "Value"
        }
    }

    // MARK: - Plugins
    struct Plugins: Codable {
        let volume, network, authorization, log: [String]?

        enum CodingKeys: String, CodingKey {
            case volume = "Volume"
            case network = "Network"
            case authorization = "Authorization"
            case log = "Log"
        }
    }

    // MARK: - RegistryConfig
    struct RegistryConfig: Codable {
        let allowNondistributableArtifactsCIDRs, allowNondistributableArtifactsHostnames, insecureRegistryCIDRs: [String]
        let indexConfigs: [String: IndexConfig]
        let mirrors: [String]

        enum CodingKeys: String, CodingKey {
            case allowNondistributableArtifactsCIDRs = "AllowNondistributableArtifactsCIDRs"
            case allowNondistributableArtifactsHostnames = "AllowNondistributableArtifactsHostnames"
            case insecureRegistryCIDRs = "InsecureRegistryCIDRs"
            case indexConfigs = "IndexConfigs"
            case mirrors = "Mirrors"
        }
    }

    // MARK: - IndexConfig
    struct IndexConfig: Codable {
        let name: String
        let mirrors: [String]
        let secure, official: Bool

        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case mirrors = "Mirrors"
            case secure = "Secure"
            case official = "Official"
        }
    }

    // MARK: - Runtimes
    struct Runtimes: Codable {
        let runc, runcMaster: Runc?
        let custom: Custom?

        enum CodingKeys: String, CodingKey {
            case runc
            case runcMaster = "runc-master"
            case custom
        }
    }

    // MARK: - Custom
    struct Custom: Codable {
        let path: String
        let runtimeArgs: [String]
    }

    // MARK: - Runc
    struct Runc: Codable {
        let path: String
    }

    // MARK: - Swarm
    struct Swarm: Codable {
        let nodeID, nodeAddr, localNodeState: String
        let controlAvailable: Bool
        let error: String
        let remoteManagers: [RemoteManager]?
        let nodes, managers: Int?
        let cluster: Cluster?

        enum CodingKeys: String, CodingKey {
            case nodeID = "NodeID"
            case nodeAddr = "NodeAddr"
            case localNodeState = "LocalNodeState"
            case controlAvailable = "ControlAvailable"
            case error = "Error"
            case remoteManagers = "RemoteManagers"
            case nodes = "Nodes"
            case managers = "Managers"
            case cluster = "Cluster"
        }
    }

    // MARK: - Cluster
    struct Cluster: Codable {
        let id: String
        let version: Version
        let createdAt, updatedAt: String
        let spec: Spec
        let tlsInfo: TLSInfo
        let rootRotationInProgress: Bool
        let dataPathPort: Int
        let defaultAddrPool: [[String]]?
        let subnetSize: Int

        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case version = "Version"
            case createdAt = "CreatedAt"
            case updatedAt = "UpdatedAt"
            case spec = "Spec"
            case tlsInfo = "TLSInfo"
            case rootRotationInProgress = "RootRotationInProgress"
            case dataPathPort = "DataPathPort"
            case defaultAddrPool = "DefaultAddrPool"
            case subnetSize = "SubnetSize"
        }
    }

    // MARK: - Spec
    struct Spec: Codable {
        let name: String
        let labels: Labels
        let orchestration: Orchestration
        let raft: Raft
        let dispatcher: Dispatcher
        let caConfig: CAConfig
        let encryptionConfig: EncryptionConfig
        let taskDefaults: TaskDefaults

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
    }

    // MARK: - CAConfig
    struct CAConfig: Codable {
        let nodeCERTExpiry: Int
        let externalCAs: [ExternalCA]
        let signingCACERT, signingCAKey: String
        let forceRotate: Int

        enum CodingKeys: String, CodingKey {
            case nodeCERTExpiry = "NodeCertExpiry"
            case externalCAs = "ExternalCAs"
            case signingCACERT = "SigningCACert"
            case signingCAKey = "SigningCAKey"
            case forceRotate = "ForceRotate"
        }
    }

    // MARK: - ExternalCA
    struct ExternalCA: Codable {
        let externalCAProtocol, url: String
        let options: ExternalCAOptions
        let caCERT: String

        enum CodingKeys: String, CodingKey {
            case externalCAProtocol = "Protocol"
            case url = "URL"
            case options = "Options"
            case caCERT = "CACert"
        }
    }

    // MARK: - ExternalCAOptions
    struct ExternalCAOptions: Codable {
        let property1, property2: String
    }

    // MARK: - Dispatcher
    struct Dispatcher: Codable {
        let heartbeatPeriod: Int

        enum CodingKeys: String, CodingKey {
            case heartbeatPeriod = "HeartbeatPeriod"
        }
    }

    // MARK: - EncryptionConfig
    struct EncryptionConfig: Codable {
        let autoLockManagers: Bool

        enum CodingKeys: String, CodingKey {
            case autoLockManagers = "AutoLockManagers"
        }
    }

    // MARK: - Labels
    struct Labels: Codable {
        let comExampleCorpType, comExampleCorpDepartment: String

        enum CodingKeys: String, CodingKey {
            case comExampleCorpType = "com.example.corp.type"
            case comExampleCorpDepartment = "com.example.corp.department"
        }
    }

    // MARK: - Orchestration
    struct Orchestration: Codable {
        let taskHistoryRetentionLimit: Int

        enum CodingKeys: String, CodingKey {
            case taskHistoryRetentionLimit = "TaskHistoryRetentionLimit"
        }
    }

    // MARK: - Raft
    struct Raft: Codable {
        let snapshotInterval, keepOldSnapshots, logEntriesForSlowFollowers, electionTick: Int
        let heartbeatTick: Int

        enum CodingKeys: String, CodingKey {
            case snapshotInterval = "SnapshotInterval"
            case keepOldSnapshots = "KeepOldSnapshots"
            case logEntriesForSlowFollowers = "LogEntriesForSlowFollowers"
            case electionTick = "ElectionTick"
            case heartbeatTick = "HeartbeatTick"
        }
    }

    // MARK: - TaskDefaults
    struct TaskDefaults: Codable {
        let logDriver: LogDriver

        enum CodingKeys: String, CodingKey {
            case logDriver = "LogDriver"
        }
    }

    // MARK: - LogDriver
    struct LogDriver: Codable {
        let name: String
        let options: LogDriverOptions

        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case options = "Options"
        }
    }

    // MARK: - LogDriverOptions
    struct LogDriverOptions: Codable {
        let maxFile, maxSize: String

        enum CodingKeys: String, CodingKey {
            case maxFile = "max-file"
            case maxSize = "max-size"
        }
    }

    // MARK: - TLSInfo
    struct TLSInfo: Codable {
        let trustRoot, certIssuerSubject, certIssuerPublicKey: String

        enum CodingKeys: String, CodingKey {
            case trustRoot = "TrustRoot"
            case certIssuerSubject = "CertIssuerSubject"
            case certIssuerPublicKey = "CertIssuerPublicKey"
        }
    }

    // MARK: - Version
    struct Version: Codable {
        let index: Int

        enum CodingKeys: String, CodingKey {
            case index = "Index"
        }
    }

    // MARK: - RemoteManager
    struct RemoteManager: Codable {
        let nodeID, addr: String

        enum CodingKeys: String, CodingKey {
            case nodeID = "NodeID"
            case addr = "Addr"
        }
    }
}
