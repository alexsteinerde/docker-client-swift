import Foundation

// MARK: - SystemInformationResponse
public struct SystemInformation: Codable {
    /// Unique identifier of the daemon.
    public let id: String
    
    /// Total number of containers on the host.
    public let containers: UInt
    
    /// Number of containers with status "running".
    public let containersRunning: UInt
    
    /// Number of containers with status "paused".
    public let containersPaused: UInt
    
    /// Number of containers with status "stopped".
    public let containersStopped: UInt
    
    /// Total number of images on the host. Both tagged and untagged (dangling) images are counted.
    public let images: UInt
    
    /// Name of the storage driver in use.
    public let storageDriver: String
    
    /// Information specific to the storage driver, provided as "label" / "value" pairs.
    public let storageDriverStatus: [[String]]
    
    /// Root directory of persistent Docker state. Defaults to `/var/lib/docker` on Linux, and `C:\ProgramData\docker` on Windows.
    public let dockerRootDir: String
    
    /// Available plugins per type.
    /// Note: Only unmanaged (V1) plugins are included in this list. V1 plugins are "lazily" loaded, and are not returned in this list if there is no resource using the plugin.
    public let plugins: Plugins?
    
    /// Indicates if the host has memory limit support enabled.
    public let memoryLimit: Bool
    
    /// Indicates if the host has memory swap limit support enabled.
    public let swapLimit: Bool
    
    /// Indicates if the host has kernel memory limit support enabled.
    @available(*, deprecated, message: "This field is deprecated as the kernel 5.4 deprecated `kmem.limit_in_bytes`")
    public let kernelMemory: Bool
    
    /// Indicates if the host has kernel memory TCP limit support enabled.
    /// Kernel memory TCP limits are not supported when using cgroups v2, which does not support the corresponding memory.kmem.tcp.limit_in_bytes cgroup.
    public let kernelMemoryTCP: Bool
    
    /// Indicates if CPU CFS (Completely Fair Scheduler) period is supported by the host.
    public let cpuCfsPeriod: Bool
    
    /// Indicates if CPU CFS (Completely Fair Scheduler) quota is supported by the host.
    public let cpuCfsQuota: Bool
    
    /// Indicates if CPU Shares limiting is supported by the host.
    public let cpuShares: Bool
    
    /// Indicates if CPUsets (cpuset.cpus, cpuset.mems) are supported by the host.
    public let cpuSet: Bool
    
    /// Indicates if the host kernel has PID limit support enabled.
    public let pidsLimit: Bool
    
    /// Indicates if disabling the OOM killer is supported on the host.
    public let oomKillDisable: Bool
    
    /// Indicates IPv4 forwarding is enabled.
    public let iPv4Forwarding: Bool
    
    /// Indicates if `bridge-nf-call-iptables` is available on the host.
    public let bridgeNfIptables: Bool
    public let bridgeNfIp6Tables: Bool
    
    /// Indicates if the daemon is running in debug-mode / with debug-level logging enabled.
    public let debug: Bool
    
    /// The total number of file Descriptors in use by the daemon process.
    /// This information is only returned if debug-mode is enabled.
    public let nFD: UInt
    
    /// The number of goroutines that currently exist.
    /// This information is only returned if debug-mode is enabled.
    public let nGoroutines: UInt
    
    /// Current system-time in RFC 3339 format with nano-seconds.
    public let systemTime: Date
    
    /// The logging driver to use as a default for new containers.
    public let loggingDriver: String
    
    /// The cgroup driver the daemon is using; cgroupfs or systemd.
    /// Returns `none` when the daemon is running in rootless mode
    public let cgroupDriver: String
    
    /// The cgroup version
    public let cgroupVersion: String
    
    public let nEventsListener: Int
    public let kernelVersion, operatingSystem, osVersion, osType: String
    
    /// Hardware architecture of the host, as returned by the Go runtime (GOARCH).
    public let architecture: String
    
    /// The number of logical CPUs usable by the daemon.
    public let ncpu: UInt16
    
    /// Total amount of physical memory available on the host, in bytes.
    public let memTotal: UInt64
    
    /// Address / URL of the index server that is used for image search, and as a default for user authentication for Docker Hub and Docker Cloud.
    /// Default: "https://index.docker.io/v1/"
    public let indexServerAddress: String
    
    public let registryConfig: RegistryConfig
    
    /// User-defined resources can be either Integer resources (e.g, SSD=3) or String resources (e.g, GPU=UUID1).
    public let genericResources: [GenericResource]?
    
    /// HTTP proxy configured for the daemon. This value is obtained from the `HTTP_PROXY` environment variable. Credentials (user info component) in the proxy URL are masked in the API response.
    /// Note: Containers do not automatically inherit this configuration.
    public let httpProxy: String
    
    /// HTTPS proxy configured for the daemon. This value is obtained from the `HTTPS_PROXY` environment variable. Credentials (user info component) in the proxy URL are masked in the API response.
    /// Note: Containers do not automatically inherit this configuration.
    public let httpsProxy: String
    
    /// Comma-separated list of domain extensions for which no proxy should be used. This value is obtained from the `NO_PROXY` environment variable.
    /// Note: Containers do not automatically inherit this configuration.
    public let noProxy: String
    
    /// Hostname of the host where the Docker deamon is running.
    public let name: String
    
    public let labels: [String]
    
    /// Indicates if experimental features are enabled on the daemon.
    public let experimentalBuild: Bool
    
    /// Version string of the daemon.
    public let serverVersion: String
    
    /// URL of the distributed storage backend.
    /// Deprecated: This field is only propagated when using standalone Swarm mode, and overlay networking using an external k/v store.
    /// Overlay networks with Swarm mode enabled use the built-in raft store, and this field will be empty.
    @available(*, deprecated, message: "This field was only propagated when using standalone Swarm mode")
    public let clusterStore: String?
    
    /// The network endpoint that the Engine advertises for the purpose of node discovery. `clusterAdvertise` is a host:port combination on which the daemon is reachable by other hosts.
    /// Deprecated: This field is only propagated when using standalone Swarm mode, and overlay networking using an external k/v store.
    /// Overlay networks with Swarm mode enabled use the built-in raft store, and this field will be empty.
    @available(*, deprecated, message: "This field was only propagated when using standalone Swarm mode")
    public let clusterAdvertise: String?
    
    public let runtimes: Runtimes?
    
    /// Name of the default OCI runtime that is used when starting containers.
    /// The default can be overridden per-container at create time.
    public let defaultRuntime: String
    
    public let swarm: SwarmInfo?
    
    /// Indicates if live restore is enabled.
    /// If enabled, containers are kept running when the daemon is shutdown or upon daemon start if running containers are detected.
    public let liveRestoreEnabled: Bool
    
    /// Represents the isolation technology to use as a default for containers. The supported values are platform-specific.
    /// Valid values: "default" "hyperv" "process"
    public let isolation: String

    /// Name and optional, path of the `docker-init` binary.
    public let initBinary: String
    
    public let containerdCommit, runcCommit, initCommit: Commit
    
    /// List of security features that are enabled on the daemon, such as apparmor, seccomp, SELinux, user-namespaces (userns), and rootless.
    public let securityOptions: [String]
    
    /// Reports a summary of the product license on the daemon.
    /// If a commercial license has been applied to the daemon, information such as number of nodes, and expiration are included.
    public let productLicense: String?
    
    /// List of custom default address pools for local networks, which can be specified in the daemon.json file or dockerd option.
    /// Example: a Base "10.10.0.0/16" with Size 24 will define the set of 256 10.10.[0-255].0/24 address pools.
    public let defaultAddressPools: [DefaultAddressPool]?
    
    /// List of warnings / informational messages about missing features, or issues related to the daemon configuration.
    public let warnings: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case containers = "Containers"
        case containersRunning = "ContainersRunning"
        case containersPaused = "ContainersPaused"
        case containersStopped = "ContainersStopped"
        case images = "Images"
        case storageDriver = "Driver"
        case storageDriverStatus = "DriverStatus"
        case dockerRootDir = "DockerRootDir"
        case plugins = "Plugins"
        case memoryLimit = "MemoryLimit"
        case swapLimit = "SwapLimit"
        case kernelMemory = "KernelMemory"
        case kernelMemoryTCP = "KernelMemoryTCP"
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
        case nFD = "NFd"
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
    
    // MARK: - Commit
    public struct Commit: Codable {
        public let id, expected: String
        
        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case expected = "Expected"
        }
    }
    
    // MARK: - DefaultAddressPool
    public struct DefaultAddressPool: Codable {
        let base, size: String
        
        enum CodingKeys: String, CodingKey {
            case base = "Base"
            case size = "Size"
        }
    }
}


// MARK: - GenericResource
/// User-defined container resources can be either Integer resources (e.g, SSD=3) or String resources (e.g, GPU=UUID1).
public struct GenericResource: Codable {
    public var discreteResourceSpec: DiscreteResourceSpec?
    public var namedResourceSpec: NamedResourceSpec?
    
    enum CodingKeys: String, CodingKey {
        case discreteResourceSpec = "DiscreteResourceSpec"
        case namedResourceSpec = "NamedResourceSpec"
    }
}

// MARK: - DiscreteResourceSpec
public struct DiscreteResourceSpec: Codable {
    public var kind: String
    public var value: Int
    
    enum CodingKeys: String, CodingKey {
        case kind = "Kind"
        case value = "Value"
    }
}

// MARK: - NamedResourceSpec
public struct NamedResourceSpec: Codable {
    public var kind, value: String
    
    enum CodingKeys: String, CodingKey {
        case kind = "Kind"
        case value = "Value"
    }
}

// MARK: - Plugins
public struct Plugins: Codable {
    public let volume, network, authorization, log: [String]?
    
    enum CodingKeys: String, CodingKey {
        case volume = "Volume"
        case network = "Network"
        case authorization = "Authorization"
        case log = "Log"
    }
}

// MARK: - RegistryConfig
public struct RegistryConfig: Codable {
    public let allowNondistributableArtifactsCIDRs, allowNondistributableArtifactsHostnames, insecureRegistryCIDRs: [String]
    public let indexConfigs: [String: IndexConfig]
    public let mirrors: [String]
    
    enum CodingKeys: String, CodingKey {
        case allowNondistributableArtifactsCIDRs = "AllowNondistributableArtifactsCIDRs"
        case allowNondistributableArtifactsHostnames = "AllowNondistributableArtifactsHostnames"
        case insecureRegistryCIDRs = "InsecureRegistryCIDRs"
        case indexConfigs = "IndexConfigs"
        case mirrors = "Mirrors"
    }
}

// MARK: - IndexConfig
public struct IndexConfig: Codable {
    public let name: String
    public let mirrors: [String]
    public let secure, official: Bool
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case mirrors = "Mirrors"
        case secure = "Secure"
        case official = "Official"
    }
}

// MARK: - Runtimes
public struct Runtimes: Codable {
    public let runc, runcMaster: Runc?
    public let custom: Custom?
    
    enum CodingKeys: String, CodingKey {
        case runc
        case runcMaster = "runc-master"
        case custom
    }
    
    // MARK: - Custom
    public struct Custom: Codable {
        public let path: String
        public let runtimeArgs: [String]
    }
    
    // MARK: - Runc
    public struct Runc: Codable {
        public let path: String
    }
}

// MARK: - Swarm
public struct SwarmInfo: Codable {
    public let nodeID, nodeAddr, localNodeState: String
    public let controlAvailable: Bool
    public let error: String
    public let remoteManagers: [RemoteManager]?
    public let nodes, managers: Int?
    public let cluster: ClusterInfo?
    
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
    
    // MARK: - ClusterInfo
    public struct ClusterInfo: Codable {
        public let id: String
        public let version: SwarmVersion
        public let createdAt, updatedAt: Date
        public let spec: SwarmSpec
        public let tlsInfo: SwarmTLSInfo
        public let rootRotationInProgress: Bool
        public let dataPathPort: Int
        public let defaultAddrPool: [String]?
        public let subnetSize: Int
        
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
    
    // MARK: - RemoteManager
    public struct RemoteManager: Codable {
        public let nodeID, addr: String
        
        enum CodingKeys: String, CodingKey {
            case nodeID = "NodeID"
            case addr = "Addr"
        }
    }
}

// MARK: - SwarmVersion
public struct SwarmVersion: Codable {
    public let index: UInt64
    
    enum CodingKeys: String, CodingKey {
        case index = "Index"
    }
}

// MARK: - SwarmTLSInfo
public struct SwarmTLSInfo: Codable {
    public let trustRoot, certIssuerSubject, certIssuerPublicKey: String
    
    enum CodingKeys: String, CodingKey {
        case trustRoot = "TrustRoot"
        case certIssuerSubject = "CertIssuerSubject"
        case certIssuerPublicKey = "CertIssuerPublicKey"
    }
    }
