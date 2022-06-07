import Foundation
import BetterCodable

/// Detailed information about a Container
public struct Container: Codable {
    
    public let appArmorProfile: String?
    
    /// The arguments to the command being run
    public let args: [String]
    
    /// Configuration for a container that is portable between hosts.
    public let config: ContainerConfig
    
    /// Container configuration that depends on the host we are running on
    public let hostConfig: HostConfig
    
    /// The time the container was created
    public let createdAt: Date
    
    /// The storage driver used to store the container's and image's filesystem.
    public let storageDriver: String
    
    public let execIDs: [String]?
    
    // TODO: let GraphDriver
    
    public let hostnamePath: String
    public let hostsPath: String
    
    /// The ID of the container
    public let id: String
    
    /// The container's image ID
    public let image: String
    
    public let logPath: String
    
    public let mountLabel: String
    
    // TODO: let Mounts
    
    public let name: String
    
    // TODO: let NetworkSettings
    
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
        case createdAt = "Created"
        case storageDriver = "Driver"
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
        /// The time to wait between checks, in nanoseconds.
        /// It should be 0 or at least 1000000 (1 ms). 0 means inherit.
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
        @DateValue<ISO8601Strategy>
        private(set)public var startedAt: Date
        
        /// The time when this container last exited.
        @DateValue<ISO8601Strategy>
        private(set)public var finishedAt: Date
        
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
        public let attachStderr: Bool
        
        public let attachStdin: Bool
        
        public let attachStdout: Bool
        
        public var cmd: [String] = []
        
        public let domainname: String
        
        public var entrypoint: [String]?
        
        /// A list of environment variables to set inside the container in the form `["VAR=value", ...].`
        /// A variable without `=` is removed from the environment, rather than to have an empty value.
        public let env: [String]
        
        /// An object mapping ports to an empty object in the form:
        /// `{"<port>/<tcp|udp|sctp>": {}}`
        public let exposedPorts: [String:EmptyObject]?
        
        /// A test to perform to periodically check that the container is healthy.
        public let healthcheck: HealthCheckConfig?
        
        /// The hostname to use for the container, as a valid RFC 1123 hostname.
        public let hostname: String
        
        public let image: String
        public var labels: [String:String]?
        public var macAddress: String?
        
        /// Whether networking is disabled for the container.
        public var networkDisabled: Bool?
        
        /// `ONBUILD` metadata that were defined in the image's `Dockerfile`
        public let onBuild: [String]?
        
        public let openStdin: Bool
        
        /// Shell for when `RUN`, `CMD`, and `ENTRYPOINT` uses a shell.
        public let shell: [String]?
        
        /// Close stdin after one attached client disconnects
        public let stdinOnce: Bool
        
        /// Unix signal to stop a container as a string or unsigned integer.
        public let stopSignal: StopSignal?
        
        /// Timeout to stop a container, in seconds.
        /// After that, the container will be forcibly killed.
        public let stopTimeout: UInt?
        
        /// Attach standard streams to a TTY, including stdin if it is not closed.
        public let tty: Bool
        
        /// The user that commands are run as inside the container.
        public let user: String
        
        /// An object mapping mount point paths inside the container to empty objects.
        public let volumes: [String:EmptyObject]??
        
        /// The working directory for commands to run in.
        public let workingDir: String
        
        enum CodingKeys: String, CodingKey {
            case attachStderr = "AttachStderr"
            case attachStdout = "AttachStdout"
            case attachStdin = "AttachStdin"
            case cmd = "Cmd"
            case domainname = "Domainname"
            case entrypoint = "Entrypoint"
            case env = "Env"
            case exposedPorts = "ExposedPorts"
            case healthcheck = "Healthcheck"
            case hostname = "Hostname"
            case image = "Image"
            case labels = "Labels"
            case macAddress = "MacAddress"
            case networkDisabled = "NetworkDisabled"
            case onBuild = "OnBuild"
            case openStdin = "OpenStdin"
            case shell = "Shell"
            case stdinOnce = "StdinOnce"
            case stopSignal = "StopSignal"
            case stopTimeout = "StopTimeout"
            case tty = "Tty"
            case user = "User"
            case volumes = "Volumes"
            case workingDir = "WorkingDir"
        }
        
        public enum StopSignal: String, Codable {
            
            case hup = "SIGHUP"
            case int = "SIGINT"
            case quit = "SIGQUIT"
            case ill = "SIGILL"
            case trap = "SIGTRAP"
            case abrt = "SIGABRT"
            case bus = "SIGBUS"
            case fpe = "SIGFPE"
            case kill = "SIGKILL"
            case usr1 = "SIGUSR1"
            case segv = "SIGSEGV"
            case usr2 = "SIGUSR2"
            case pipe = "SIGPIPE"
            case alrm = "SIGALRM"
            case term = "SIGTERM"
            
            
            
            
        }
    }
    
    public struct ContainerDeviceMapping: Codable {
        public let cgroupPermissions: String
        public let pathInContainer: String
        public let pathOnHost: String
        
        enum CodingKeys: String, CodingKey {
            case cgroupPermissions = "CgroupPermissions"
            case pathInContainer = "PathInContainer"
            case pathOnHost = "PathOnHost"
        }
    }
    
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
    
    public struct ContainerMount: Codable {
        // var BindOptions
        public var Consistency: MountConsistency
        public var ReadOnly: Bool
        public var Source: String
        public var Target: String
        public var `Type`: MountType
        // var VolumeOptions
        // var TmpfsOptions
        
        public enum MountType: String, Codable {
            case bind, volume, tmpfs, npipe
        }
        
        public enum MountConsistency: String, Codable {
            case cached, consistent, `default`, delegated
        }
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
