import Foundation

/// Detailed information about a Container
public struct Container: Codable {
    
    public let appArmorProfile: String?
    
    /// The arguments to the command being run
    public let args: [String]
    
    /// Configuration for a container that is portable between hosts.
    public let config: ContainerConfig
    
    /// The time the container was created
    public let created: Date
    
    public let driver: String
    public let execIDs: [String]?
    // let GraphDriver
    
    /// Container configuration that depends on the host we are running on
    public let hostConfig: HostConfig
    
    public let hostnamePath: String
    public let hostsPath: String
    
    /// The ID of the container
    public let id: String
    
    public let image: String
    public let logPath: String
    public let mountLabel: String
    // let Mounts
    public let name: String
    //let NetworkSettings
    public let platform: String
    
    /// The path to the command being run
    public let path: String
    
    public let processLabel: String
    public let resolvConfPath: String
    public let restartCount: UInt64
    
    /// The total size of all the files in this container.
    public let sizeRootFs: UInt64?
    
    /// The size of files that have been created or changed by this container.
    public let sizeRw: UInt64?
    
    public let state: State
    
    enum CodingKeys: String, CodingKey {
        case appArmorProfile = "AppArmorProfile"
        case args = "Args"
        case config = "Config"
        case created = "Created"
        case driver = "Driver"
        case execIDs = "ExecIDs"
        case hostConfig = "HostConfig"
        case hostnamePath = "HostnamePath"
        case hostsPath = "HostsPath"
        case id = "Id"
        case image = "Image"
        case logPath = "LogPath"
        case mountLabel = "MountLabel"
        case name = "Name"
        case platform = "Platform"
        case path = "Path"
        case processLabel = "ProcessLabel"
        case resolvConfPath = "ResolvConfPath"
        case restartCount = "RestartCount"
        case sizeRootFs = "SizeRootFs"
        case sizeRw = "SizeRw"
        case state = "State"
    }
    
    public enum HealthStatus: String, Codable {
        case none, starting, healthy, unhealthy
    }
    
    public struct HealthcheckResult: Codable {
        var start: String
        var end: String
        var exitCode: Int
        var output: String
        
        enum CodingKeys: String, CodingKey {
            case start = "Start"
            case end = "End"
            case exitCode = "ExitCode"
            case output = "Output"
        }
    }
    
    public struct HealthCheckConfig: Codable {
        /// The time to wait between checks in nanoseconds. It should be 0 or at least 1000000 (1 ms). 0 means inherit.
        public var interval: UInt64
        
        /// The number of consecutive failures needed to consider a container as unhealthy. 0 means inherit.
        public var retries: UInt
        
        /// Start period for the container to initialize before starting health-retries countdown in nanoseconds.
        /// It should be 0 or at least 1000000 (1 ms). 0 means inherit.
        public var startPeriod: UInt64
        
        /// The test to perform. Possible values are
        /// - `[]` : inherit healthcheck from image or parent image)
        /// - `["NONE"]` : disable healthcheck
        /// - `["CMD", args...]` exec arguments directly
        /// - ["CMD-SHELL", command]` run command with system's default shell
        public var test: [String]
        
        /// The time to wait before considering the check to have hung. It should be 0 or at least 1000000 (1 ms). 0 means inherit.
        public var timeout: UInt64
        
        enum CodingKeys: String, CodingKey {
            case interval = "Interval"
            case retries = "Retries"
            case startPeriod = "StartPeriod"
            case test = "Test"
            case timeout = "Timeout"
        }
    }
    
    public struct HealthResponse: Codable {
        public let status: HealthStatus
        
        /// Number of consecutive failures
        public let failingStreak: UInt64
        
        public let log: [HealthcheckResult]
        
        enum CodingKeys: String, CodingKey {
            case status = "Status"
            case failingStreak = "FailingStreak"
            case log = "Log"
        }
    }
    
    public struct State: Codable {
        public let dead: Bool
        
        public let error: String
        
        /// The last exit code of this container
        public let exitCode: Int
        
        /// Health stores information about the container's healthcheck results.
        public let health: HealthResponse?
        
        /// Whether this container has been killed because it ran out of memory.
        public let oomKilled: Bool
        
        public let paused: Bool
        
        /// The process ID of this container
        public let pid: UInt64
        
        public let running: Bool
        
        public let restarting: Bool
        
        /// The time when this container was last started.
        public let startedAt: String
        
        /// The time when this container last exited.
        public let finishedAt: String
        
        public let status: String
        
        enum CodingKeys: String, CodingKey {
            case dead = "Dead"
            case error = "Error"
            case exitCode = "ExitCode"
            case health = "Health"
            case finishedAt = "FinishedAt"
            case oomKilled = "OOMKilled"
            case paused = "Paused"
            case pid = "Pid"
            case running = "Running"
            case restarting = "Restarting"
            case startedAt = "StartedAt"
            case status = "Status"
        }
    }
    
    public struct EmptyObject: Codable {}
    
    public struct ContainerConfig: Codable {
        public let AttachStderr: Bool
        public let AttachStdin: Bool
        public let AttachStdout: Bool
        public var Cmd: [String] = []
        public let Domainname: String
        public var Entrypoint: [String]?
        
        /// A list of environment variables to set inside the container in the form `["VAR=value", ...].`
        /// A variable without `=` is removed from the environment, rather than to have an empty value.
        public let Env: [String]
        
        public let ExposedPorts: [String:EmptyObject]?
        
        public let Healthcheck: HealthCheckConfig?
        
        /// The hostname to use for the container, as a valid RFC 1123 hostname.
        public let Hostname: String
        
        public let Image: String
        public var Labels: [String:String]?
        public var MacAddress: String?
        
        /// Whether networking is disabled for the container.
        public var NetworkDisabled: Bool?
        
        /// `ONBUILD` metadata that were defined in the image's `Dockerfile`
        public let OnBuild: [String]?
        
        public let OpenStdin: Bool
        
        /// Shell for when `RUN`, `CMD`, and `ENTRYPOINT` uses a shell.
        public let Shell: [String]?
        
        /// Close stdin after one attached client disconnects
        public let StdinOnce: Bool
        
        /// Unix signal to stop a container as a string or unsigned integer.
        public let StopSignal: String?
        
        public let StopTimeout: UInt?
        
        /// Attach standard streams to a TTY, including stdin if it is not closed.
        public let Tty: Bool
        
        /// The user that commands are run as inside the container.
        public let User: String
        
        public let Volumes: [String:EmptyObject]??
        
        public let WorkingDir: String
        
    }
    
    public struct ContainerDeviceMapping: Codable {
        public let CgroupPermissions: String
        public let PathInContainer: String
        public let PathOnHost: String
    }
    
    public  struct Ulimit: Codable {
        public var Name: String
        public var Soft: UInt64
        public var Hard: UInt64
    }
    
    public enum MountType: String, Codable {
        case bind, volume, tmpfs, npipe
    }
    
    public enum MountConsistency: String, Codable {
        case cached, consistent, `default`, delegated
    }
    
    public struct ContainerMount: Codable {
        // var BindOptions
        public var Consistency: MountConsistency
        public var ReadOnly: Bool
        public var Source: String
        public var Target: String
        public var `Type`: MountType
        // var VolumeOptions
        // var TmpfsOptions
    }
    
    public struct HostConfig: Codable {
        /// A list of volume bindings for this container. Each volume binding is a string in one of these forms:
        ///- `host-src:container-dest[:options]` to bind-mount a host path into the container. Both host-src, and container-dest must be an absolute path.
        /// - `volume-name:container-dest[:options]` to bind-mount a volume managed by a volume driver into the container. container-dest must be an absolute path.
        public let Binds: [String]?
        
        /// Block IO weight (relative weight).
        /// Allowed values range: [ 0 .. 1000 ]
        public let BlkioWeight: UInt
        
        /// A list of kernel capabilities to add to the container. Conflicts with option 'Capabilities'.
        public let CapAdd: [String]?
        
        /// A list of kernel capabilities to drop from the container. Conflicts with option 'Capabilities'.
        public let CapDrop: [String]?
        
        /// Cgroup to use for the container.
        public let Cgroup: String
        
        // let CgroupnsMode
        
        /// Path to cgroups under which the container's cgroup is created.
        /// If the path is not absolute, the path is considered to be relative to the cgroups path of the init process.
        /// Cgroups are created if they do not already exist.
        public let CgroupParent: String
        
        /// Path to a file where the container ID is written
        public let ContainerIDFile: String?
        
        /// The length of a CPU period in microseconds.
        public let CpuPeriod: UInt64
        
        /// Microseconds of CPU time that the container can get in a CPU period.
        public let CpuQuota: UInt64
        
        /// The length of a CPU real-time period in microseconds. Set to 0 to allocate no time allocated to real-time tasks.
        public let CpuRealtimePeriod: UInt64
        
        /// The length of a CPU real-time runtime in microseconds. Set to 0 to allocate no time allocated to real-time tasks.
        public let CpuRealtimeRuntime: UInt64
        
        /// CPUs in which to allow execution (e.g., `0-3`, `0,1`).
        public let CpusetCpus: String
        
        /// Memory nodes (MEMs) in which to allow execution (`0-3`, `0,1`). Only effective on NUMA systems.
        public let CpusetMems: String
        
        /// Value representing this container's relative CPU weight versus other containers.
        public let CpuShares: UInt
        
        public let Devices: [ContainerDeviceMapping]?
        
        /// A list of cgroup rules to apply to the container
        public let DeviceCgroupRules: [String]?
        
        /// A list of DNS servers for the container to use.
        public let Dns: [String]?
        
        /// A list of DNS options.
        public let DnsOptions: [String]?
        
        /// A list of DNS search domains.
        public let DnsSearch: [String]?
        
        /// A list of hostnames/IP mappings to add to the container's /etc/hosts file. Specified in the form `["hostname:IP"]`.
        public let ExtraHosts: [String]?
        
        /// A list of additional groups that the container process will run as.
        public let GroupAdd: [String]?
        
        /// Run an init inside the container that forwards signals and reaps processes.
        /// This field is omitted if empty, and the default (as configured on the daemon) is used.
        public let Init: Bool?
        
        /// IPC sharing mode for the container. Possible values are:
        /// - `none`: own private IPC namespace, with /dev/shm not mounted
        /// - `private`: own private IPC namespace
        /// - `shareable`: own private IPC namespace, with a possibility to share it with other containers
        /// - `container:<name|id>`: join another (shareable) container's IPC namespace
        /// - `host`: use the host system's IPC namespace
        /// If not specified, daemon default is used, which can either be `private` or `shareable`, depending on daemon version and configuration.
        public let IpcMode: String?
        
        /// Kernel memory limit in bytes.
        /// **Deprecated**: This field is deprecated as the kernel 5.4 deprecated `kmem.limit_in_bytes`.
        @available(*, deprecated)
        public let KernelMemory: UInt64
        
        /// Hard limit for kernel TCP buffer memory (in bytes).
        public let KernelMemoryTCP: UInt64
        
        /// A list of links for the container in the form `container_name:alias`.
        public let Links: [String]?
        
        // TODO: implement
        // let LogConfig
        
        /// The list of paths to be masked inside the container (this overrides the default set of paths).
        public let MaskedPaths: [String]
        
        /// Memory limit in bytes.
        public let Memory: UInt64
        
        /// Memory soft limit in bytes.
        public let MemoryReservation: UInt64
        
        /// Total memory limit (memory + swap). Set as -1 to enable unlimited swap.
        public let MemorySwap: UInt64
        
        /// Tune a container's memory swappiness behavior. Accepts an integer between 0 and 100.
        public let MemorySwappiness: UInt8?
        
        /// Specification for mounts to be added to the container.
        public let Mounts: [ContainerMount]?
        
        /// CPU quota in units of 10^-9 CPUs.
        public let NanoCpus: UInt64
        
        /// Network mode to use for this container. Supported standard values are: bridge, host, none, and container:<name|id>. Any other value is taken as a custom network's name to which this container should connect to.
        public let NetworkMode: String
        
        /// Disable OOM Killer for the container.
        public let OomKillDisable: Bool?
        
        /// An integer value containing the score given to the container in order to tune OOM killer preferences.
        public let OomScoreAdj: Int
        
        /// Tune a container's PIDs limit. Set `0` or `-1` for unlimited, or `null to not change.
        public let PidsLimit: UInt64?
        
        /// Set the PID (Process) Namespace mode for the container. It can be either:
        /// - `container:<name|id>`: joins another container's PID namespace
        /// - `host`: use the host's PID namespace inside the container
        public let PidMode: String
        
        // let PortBindings
        
        /// Gives the container full access to the host.
        public let Privileged: Bool
        
        /// Allocates an ephemeral host port for all of a container's exposed ports.
        /// Ports are de-allocated when the container stops and allocated when the container starts. The allocated port might be changed when restarting the container.
        /// The port is selected from the ephemeral port range that depends on the kernel. For example, on Linux the range is defined by `/proc/sys/net/ipv4/ip_local_port_range`.
        public let PublishAllPorts: Bool
        
        /// The list of paths to be set as read-only inside the container (this overrides the default set of paths).
        public let ReadonlyPaths: [String]
        
        /// Mount the container's root filesystem as read only.
        public let ReadonlyRootfs: Bool
        
        // let RestartPolicy
        
        /// Runtime to use with this container.
        public let Runtime: String?
        
        /// A list of string values to customize labels for MLS systems, such as SELinux.
        public let SecurityOpt: [String]?
        
        /// Size of `/dev/shm` in bytes. If omitted, the system uses 64MB.
        public let ShmSize: UInt
        
        /// Storage driver options for this container, in the form `{"size": "120G"}`.
        public let StorageOpt: [String:String]?
        
        // let Sysctls
        
        /// A map of container directories which should be replaced by tmpfs mounts, and their corresponding mount options. For example:
        /// `{ "/run": "rw,noexec,nosuid,size=65536k" }`
        public let Tmpfs: [String:String]?
        
        public let Ulimits: [Ulimit]?
        
        /// Sets the usernamespace mode for the container when usernamespace remapping option is enabled.
        public let UsernsMode: String
        
        /// UTS namespace to use for the container.
        public let UTSMode: String
        
    }
}
