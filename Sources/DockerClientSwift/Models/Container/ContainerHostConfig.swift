import Foundation

// MARK: - ContainerHostConfig
public struct ContainerHostConfig: Codable {
    
    /// Whether to automatically delete the container when it exits.
    public var autoRemove: Bool = false
    
    /// A list of volume bindings for this container. Each volume binding is a string in one of these forms:
    ///- `host-src:container-dest[:options]` to bind-mount a host path into the container. Both host-src, and container-dest must be an absolute path.
    /// - `volume-name:container-dest[:options]` to bind-mount a volume managed by a volume driver into the container. container-dest must be an absolute path.
    public var binds: [String]? = nil
    
    /// Block IO weight (relative weight).
    /// Allowed values range: [ 0 .. 1000 ]
    public var blkioWeight: UInt16 = 0
    
    /// Block IO weight (relative device weight)
    public var blkioWeightDevice: [BlkioWeight]? = []
    
    /// Limit read rate (bytes per second) from a device
    public var blkioDeviceReadBps: BlkioRateLimit? = nil
    
    /// Limit write rate (bytes per second) to a device
    public var blkioDeviceWriteBps: BlkioRateLimit? = nil
    
    /// Limit read rate (IO per second) from a device
    public var blkioDeviceReadIOps: BlkioRateLimit? = nil
    
    /// Limit write rate (IO per second) to a device
    public var blkioDeviceWriteIOps: BlkioRateLimit? = nil
    
    /// A list of kernel capabilities to add to the container. Conflicts with option 'Capabilities'.
    public var capabilityAdd: [String]? = nil
    
    /// A list of kernel capabilities to drop from the container. Conflicts with option 'Capabilities'.
    public var capabilityDrop: [String]? = nil
    
    /// Cgroup to use for the container.
    public var cgroup: String = ""
    
    /// cgroup namespace mode for the container. Possible values are:
    /// "private": the container runs in its own private cgroup namespace
    /// "host": use the host system's cgroup namespace
    /// If not specified, the daemon default is used, which can either be "private" or "host", depending on daemon version, kernel support and configuration.
    public var cgroupNsMode: String = ""
    
    /// Path to cgroups under which the container's cgroup is created.
    /// If the path is not absolute, the path is considered to be relative to the cgroups path of the init process.
    /// Cgroups are created if they do not already exist.
    public var cgroupParent: String = ""
    
    // Windows only
    // public let ConsoleSize: [UInt8]
    
    /// Path to a file where the container ID is written
    public var containerIdFile: String = ""
    
    /// Windows only
    /// The number of usable CPUs (Windows only).
    /// On Windows Server containers, the processor resource controls are mutually exclusive. The order of precedence is `CPUCount` first, then `CPUShares`, and `CPUPercent` last.
    public var cpuCount: UInt8 = 0
    
    /// Windows only
    public var cpuPercent: UInt8 = 0
    
    /// The length of a CPU period in microseconds.
    public var cpuPeriod: UInt64 = 0
    
    /// Microseconds of CPU time that the container can get in a CPU period.
    public var cpuQuota: UInt64 = 0
    
    /// The length of a CPU real-time period, in microseconds.
    /// Set to 0 to allocate no time allocated to real-time tasks.
    public var cpuRealtimePeriod: UInt64 = 0
    
    /// The length of a CPU real-time runtime, in microseconds.
    /// Set to 0 to allocate no time allocated to real-time tasks.
    public var cpuRealtimeRuntime: UInt64 = 0
    
    /// CPUs in which to allow execution (e.g., `0-3`, `0,1`).
    public var cpusetCpus: String = ""
    
    /// Memory nodes (MEMs) in which to allow execution (`0-3`, `0,1`). Only effective on NUMA systems.
    public var cpusetMems: String = ""
    
    /// Value representing this container's relative CPU weight versus other containers.
    public var cpuShares: UInt = 0
    
    public var devices: [DeviceMapping]? = []
    
    // TODO: implement
    // public var deviceRequests
    
    /// A list of cgroup rules to apply to the container
    public var deviceCgroupRules: [String]? = nil
    
    /// A list of DNS servers for the container to use.
    public var dns: [String]? = []
    
    /// A list of DNS options.
    public var dnsOptions: [String]? = []
    
    /// A list of DNS search domains.
    public var dnsSearch: [String]? = []
    
    /// A list of hostnames/IP mappings to add to the container's /etc/hosts file. Specified in the form `["hostname:IP"]`.
    public var extraHosts: [String]? = []
    
    /// A list of additional groups that the container process will run as.
    public var groupAdd: [String]? = nil
    
    /// Run an init inside the container that forwards signals and reaps processes.
    /// This field is omitted if empty, and the default (as configured on the daemon) is used.
    public var `init`: Bool? = false
    
    /// IPC sharing mode for the container. Possible values are:
    /// - `none`: own private IPC namespace, with /dev/shm not mounted
    /// - `private`: own private IPC namespace
    /// - `shareable`: own private IPC namespace, with a possibility to share it with other containers
    /// - `container:<name|id>`: join another (shareable) container's IPC namespace
    /// - `host`: use the host system's IPC namespace
    /// If not specified, daemon default is used, which can either be `private` or `shareable`, depending on daemon version and configuration.
    public var ipcMode: String = ""
    
    // Windows only.
    public var isolation: String = ""
    
    /// Kernel memory limit in bytes.
    /// **Deprecated**: This field is deprecated as the kernel 5.4 deprecated `kmem.limit_in_bytes`.
    @available(*, deprecated)
    public var kernelMemory: UInt64 = 0
    
    /// Hard limit for kernel TCP buffer memory (in bytes).
    public var kernelMemoryTcp: UInt64 = 0
    
    /// A list of links for the container in the form `container_name:alias`.
    public var links: [String]? = nil
    
    // TODO: implement
    // let LogConfig
    // default when create cotainer: "LogConfig\":{\"Type\":\"\",\"Config\":{}}
    
    /// The list of paths to be masked inside the container (this overrides the default set of paths).
    public var maskedPaths: [String]? = nil
    
    /// Memory limit in bytes.
    public var memoryLimit: UInt64 = 0
    
    /// Memory soft limit in bytes.
    public var memoryReservation: UInt64 = 0
    
    /// Total memory limit (memory + swap). Set as -1 to enable unlimited swap.
    public var memorySwap: Int64 = 0
    
    /// Tune a container's memory swappiness behavior. Accepts an integer between 0 and 100.
    public var memorySwappiness: Int8? = -1
    
    /// Specification for mounts to be added to the container.
    public var mounts: [ContainerMount]? = nil
    
    /// CPU quota in units of 10^-9 CPUs.
    public var nanoCpus: UInt64 = 0
    
    /// Network mode to use for this container. Supported standard values are: bridge, host, none, and container:<name|id>. Any other value is taken as a custom network's name to which this container should connect to.
    public var networkMode: String = "default"
    
    /// Disable OOM Killer for the container.
    public var oomKillDisable: Bool? = false
    
    /// An integer value containing the score given to the container in order to tune OOM killer preferences.
    public var oomScoreAdj: Int = 0
    
    /// Tune a container's PIDs limit. Set `0` or `-1` for unlimited, or `null to not change.
    public var pidsLimit: UInt64? = 0
    
    /// Set the PID (Process) Namespace mode for the container. It can be either:
    /// - `container:<name|id>`: joins another container's PID namespace
    /// - `host`: use the host's PID namespace inside the container
    public var pidMode: String = ""
    
    /// Maps container exposed ports to ports on the host. This is the API equivalent of the docker CLI `--publish` option.
    public var portBindings: [String:PortBinding] = [:]
    
    /// Gives the container full access to the host.
    public var privileged: Bool = false
    
    /// Allocates an ephemeral host port for all of a container's exposed ports.
    /// Ports are de-allocated when the container stops and allocated when the container starts. The allocated port might be changed when restarting the container.
    /// The port is selected from the ephemeral port range that depends on the kernel. For example, on Linux the range is defined by `/proc/sys/net/ipv4/ip_local_port_range`.
    public var publishAllPorts: Bool = false
    
    /// The list of paths to be set as read-only inside the container (this overrides the default set of paths).
    public var readonlyPaths: [String]? = nil
    
    /// Mount the container's root filesystem as read only.
    public var readonlyRootfs: Bool = false
    
    // let RestartPolicy
    // default when create: {\"Name\":\"no\",\"MaximumRetryCount\":0}
    
    /// Runtime to use with this container.
    public var runtime: String? = nil
    
    /// A list of string values to customize labels for MLS systems, such as SELinux.
    public var securityOpt: [String]? = nil
    
    /// Size of `/dev/shm` in bytes. If omitted, the system uses 64MB.
    public var shmSize: UInt = 0
    
    /// Storage driver options for this container, in the form `{"size": "120G"}`.
    public var storageOpt: [String:String]? = nil
    
    /// A list of kernel parameters (sysctls) to set in the container.
    /// For example: `{"net.ipv4.ip_forward": "1"}`
    public var sysctls: [String:String]? = nil
    
    /// A map of container directories which should be replaced by tmpfs mounts, and their corresponding mount options.
    /// For example: `{ "/run": "rw,noexec,nosuid,size=65536k" }`
    public var tmpfs: [String:String]? = nil
    
    /// A list of resource limits to set in the container
    public var ulimits: [Ulimit]? = nil
    
    /// Sets the usernamespace mode for the container when usernamespace remapping option is enabled.
    public var userNsMode: String = ""
    
    /// UTS namespace to use for the container.
    public var utsMode: String = ""
    
    /// Driver that this container uses to mount volumes.
    public var volumeDriver: String = ""
    
    /// A list of volumes to inherit from another container, specified in the form `<container name>[:<ro|rw>]`.
    public var volumesFrom: [String]? = nil
    
    enum CodingKeys: String, CodingKey {
        case autoRemove = "AutoRemove"
        case binds = "Binds"
        case blkioWeight = "BlkioWeight"
        case blkioWeightDevice = "BlkioWeightDevice"
        case blkioDeviceReadBps = "BlkioDeviceReadBps"
        case blkioDeviceWriteBps = "BlkioDeviceWriteBps"
        case blkioDeviceReadIOps = "BlkioDeviceReadIOps"
        case blkioDeviceWriteIOps = "BlkioDeviceWriteIOps"
        case capabilityAdd = "CapAdd"
        case capabilityDrop = "CapDrop"
        case cgroup = "Cgroup"
        case cgroupNsMode = "CgroupnsMode"
        case cgroupParent = "CgroupParent"
        case containerIdFile = "ContainerIDFile"
        case cpuCount = "CpuCount"
        case cpuPercent = "CpuPercent"
        case cpuPeriod = "CpuPeriod"
        case cpuQuota = "CpuQuota"
        case cpuRealtimePeriod = "CpuRealtimePeriod"
        case cpuRealtimeRuntime = "CpuRealtimeRuntime"
        case cpusetCpus = "CpusetCpus"
        case cpuShares = "CpuShares"
        case devices = "Devices"
        case deviceCgroupRules = "DeviceCgroupRules"
        case dns = "Dns"
        case dnsOptions = "DnsOptions"
        case dnsSearch = "DnsSearch"
        case extraHosts = "ExtraHosts"
        case groupAdd = "GroupAdd"
        case `init` = "Init"
        case ipcMode = "IpcMode"
        case isolation = "Isolation"
        case kernelMemory = "KernelMemory"
        case kernelMemoryTcp = "KernelMemoryTCP"
        case links = "Links"
        case maskedPaths = "MaskedPaths"
        case memoryLimit = "Memory"
        case memoryReservation = "MemoryReservation"
        case memorySwap = "MemorySwap"
        case memorySwappiness = "MemorySwappiness"
        case mounts = "Mounts"
        case nanoCpus = "NanoCpus"
        case networkMode = "NetworkMode"
        case oomKillDisable = "OomKillDisable"
        case oomScoreAdj = "OomScoreAdj"
        case pidsLimit = "PidsLimit"
        case pidMode = "PidMode"
        case portBindings = "PortBindings"
        case privileged = "Privileged"
        case publishAllPorts = "PublishAllPorts"
        case readonlyPaths = "ReadonlyPaths"
        case readonlyRootfs = "ReadonlyRootfs"
        case runtime = "Runtime"
        case securityOpt = "SecurityOpt"
        case shmSize = "ShmSize"
        case storageOpt = "StorageOpt"
        case sysctls = "Sysctls"
        case tmpfs = "Tmpfs"
        case ulimits = "Ulimits"
        case userNsMode = "UsernsMode"
        case utsMode = "UTSMode"
        case volumeDriver = "VolumeDriver"
        case volumesFrom = "VolumesFrom"
    }
    
    // MARK: - BlkioWeight
    public struct BlkioWeight: Codable {
        public var path: String
        public var weight: UInt
        
        enum CodingKeys: String, CodingKey {
            case path = "Path"
            case weight = "Weight"
        }
    }
    
    // MARK: - BlkioRateLimit
    public struct BlkioRateLimit: Codable {
        public var path: String
        public var rate: UInt
        
        enum CodingKeys: String, CodingKey {
            case path = "Path"
            case rate = "Rate"
        }
    }
    
    // MARK: -
    public struct DeviceMapping: Codable {
        public let cgroupPermissions: String
        public let pathInContainer: String
        public let pathOnHost: String
        
        enum CodingKeys: String, CodingKey {
            case cgroupPermissions = "CgroupPermissions"
            case pathInContainer = "PathInContainer"
            case pathOnHost = "PathOnHost"
        }
    }
    
    // MARK: - ContainerMount
    public struct ContainerMount: Codable {
        public var bindOptions: BindOptions? = nil
        public var consistency: MountConsistency? = nil
        public var readOnly: Bool
        public var source: String
        public var target: String
        public var `type`: MountType
        public var volumeOptions: VolumeOptions? = nil
        public var tmpFsOptions: TmpfsOptions? = nil
        
        enum CodingKeys: String, CodingKey {
            case bindOptions = "BindOptions"
            case consistency = "Consistency"
            case readOnly = "ReadOnly"
            case source = "Source"
            case target = "Target"
            case type = "Type"
            case volumeOptions = "VolumeOptions"
            case tmpFsOptions = "TmpfsOptions"
        }
        
        public enum MountType: String, Codable {
            case bind, volume, tmpfs, npipe
        }
        
        public enum MountConsistency: String, Codable {
            case cached, consistent, `default`, delegated
        }
        
        public struct BindOptions: Codable {
            public var propagation: BindOptionsPropagation
            public var nonRecursive: Bool = false
            
            enum CodingKeys: String, CodingKey {
                case propagation = "Propagation"
                case nonRecursive = "NonRecursive"
            }
            public enum BindOptionsPropagation: String, Codable {
                case `private`, rprivate, shared, rshared, slave, rslave
            }
        }
        
        public struct VolumeOptions: Codable {
            public var noCopy: Bool = false
            public var labels: [String:String] = [:]
            public var driverConfig: DriverConfig?
            
            enum CodingKeys: String, CodingKey {
                case noCopy = "NoCopy"
                case labels = "Labels"
                case driverConfig = "DriverConfig"
            }
        }
        
        public struct TmpfsOptions: Codable {
            public var sizeBytes: UInt64
            public var mode: Int
            
            enum CodingKeys: String, CodingKey {
                case sizeBytes = "SizeBytes"
                case mode = "Mode"
            }
        }
    }
    
    // MARK: - PortBinding
    public struct PortBinding: Codable {
        /// Host IP address that the container's port is mapped to.
        public var hostIp: String
        
        /// Host port number that the container's port is mapped to.
        public var hostPort: UInt16
        
        enum CodingKeys: String, CodingKey {
            case hostIp = "HostIp"
            case hostPort = "HostPort"
        }
    }
    
    // MARK: - Ulimit
    public struct Ulimit: Codable {
        public var name: String
        public var soft: UInt64
        public var hard: UInt64
        
        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case soft = "Soft"
            case hard = "Hard"
        }
    }
}
