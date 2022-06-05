import Foundation
import NIOHTTP1

struct InspectContainerEndpoint: Endpoint {
    typealias Body = NoBody
    typealias Response = ContainerResponse
    var method: HTTPMethod = .GET
    
    let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "containers/\(nameOrId)/json"
    }
    
    struct ContainerResponse: Codable {
        /// The arguments to the command being run
        let Args: [String]
        
        /// Configuration for a container that is portable between hosts.
        let Config: ConfigResponse
        
        /// The time the container was created
        let Created: Date
        let Driver: String
        let ExecIDs: [String]?
        // let GraphDriver
        
        /// Container configuration that depends on the host we are running on
        let HostConfig: HostConfigResponse
        
        let HostnamePath: String
        let HostsPath: String
        
        /// The ID of the container
        let Id: String
        
        let Image: String
        let LogPath: String
        let MountLabel: String
        // let Mounts
        let Name: String
        //let NetworkSettings
        let Platform: String
        
        /// The path to the command being run
        let Path: String
        
        let ProcessLabel: String
        let ResolvConfPath: String
        let RestartCount: UInt64
        
        /// The total size of all the files in this container.
        let SizeRootFs: UInt64?
        
        /// The size of files that have been created or changed by this container.
        let SizeRw: UInt64?
        
        let State: StateResponse
        
        enum HealthStatus: String, Codable {
            case none, starting, healthy, unhealthy
        }
        
        struct HealthcheckResult: Codable {
            var Start: String
            var End: String
            var ExitCode: Int
            var Output: String
        }
        
        struct HealthCheckConfig: Codable {
            /// The time to wait between checks in nanoseconds. It should be 0 or at least 1000000 (1 ms). 0 means inherit.
            var Interval: UInt64
            
            /// The number of consecutive failures needed to consider a container as unhealthy. 0 means inherit.
            var Retries: UInt
            
            /// Start period for the container to initialize before starting health-retries countdown in nanoseconds.
            /// It should be 0 or at least 1000000 (1 ms). 0 means inherit.
            var StartPeriod: UInt64
            
            /// The test to perform. Possible values are
            /// - `[]` : inherit healthcheck from image or parent image)
            /// - `["NONE"]` : disable healthcheck
            /// - `["CMD", args...]` exec arguments directly
            /// - ["CMD-SHELL", command]` run command with system's default shell
            var Test: [String]
            
            /// The time to wait before considering the check to have hung. It should be 0 or at least 1000000 (1 ms). 0 means inherit.
            var Timeout: UInt64
        }
        
        struct HealthResponse: Codable {
            let Status: HealthStatus
            /// FailingStreak is the number of consecutive failures
            let FailingStreak: UInt64
            let Log: [HealthcheckResult]
        }
        
        struct StateResponse: Codable {
            var Dead: Bool
            var Error: String
            /// The last exit code of this container
            var ExitCode: Int
            /// Health stores information about the container's healthcheck results.
            var Health: HealthResponse?
            /// The time when this container last exited.
            var FinishedAt: String
            /// Whether this container has been killed because it ran out of memory.
            var OOMKilled: Bool
            var Paused: Bool
            /// The process ID of this container
            var Pid: UInt64
            var Running: Bool
            var Restarting: Bool
            /// The time when this container was last started.
            var StartedAt: String
            var Status: String
        }
        
        struct EmptyObject: Codable {}
        
        struct ConfigResponse: Codable {
            let AttachStderr: Bool
            let AttachStdin: Bool
            let AttachStdout: Bool
            var Cmd: [String] = []
            let Domainname: String
            var Entrypoint: [String]?
            
            /// A list of environment variables to set inside the container in the form `["VAR=value", ...].`
            /// A variable without `=` is removed from the environment, rather than to have an empty value.
            let Env: [String]
            
            let ExposedPorts: [String:EmptyObject]?
            
            let Healthcheck: HealthCheckConfig?
            
            /// The hostname to use for the container, as a valid RFC 1123 hostname.
            let Hostname: String
            
            let Image: String
            var Labels: [String:String]?
            var MacAddress: String?
            
            /// Whether networking is disabled for the container.
            var NetworkDisabled: Bool?
            
            /// `ONBUILD` metadata that were defined in the image's `Dockerfile`
            let OnBuild: [String]?
            
            let OpenStdin: Bool
            
            /// Shell for when `RUN`, `CMD`, and `ENTRYPOINT` uses a shell.
            let Shell: [String]?
            
            /// Close stdin after one attached client disconnects
            let StdinOnce: Bool
            
            /// Unix signal to stop a container as a string or unsigned integer.
            let StopSignal: String?
            
            let StopTimeout: UInt?
            
            /// Attach standard streams to a TTY, including stdin if it is not closed.
            let Tty: Bool
            
            /// The user that commands are run as inside the container.
            let User: String
            
            let Volumes: [String:EmptyObject]??
            
            let WorkingDir: String
            
        }
        
        struct DeviceMapping: Codable {
            let CgroupPermissions: String
            let PathInContainer: String
            let PathOnHost: String
        }
        
        struct Ulimit: Codable {
            var Name: String
            var Soft: UInt64
            var Hard: UInt64
        }
        
        public enum MountType: String, Codable {
            case bind, volume, tmpfs, npipe
        }
        
        public enum MountConsistency: String, Codable {
            case cached, consistent, `default`, delegated
        }
        
        struct Mount: Codable {
            // var BindOptions
            var Consistency: MountConsistency
            var ReadOnly: Bool
            var Source: String
            var Target: String
            var `Type`: MountType
            // var VolumeOptions
            // var TmpfsOptions
        }
        
        struct HostConfigResponse: Codable {
            
            /// A list of volume bindings for this container. Each volume binding is a string in one of these forms:
            ///- `host-src:container-dest[:options]` to bind-mount a host path into the container. Both host-src, and container-dest must be an absolute path.
            /// - `volume-name:container-dest[:options]` to bind-mount a volume managed by a volume driver into the container. container-dest must be an absolute path.
            let Binds: [String]?
            
            /// Block IO weight (relative weight).
            /// Allowed values range: [ 0 .. 1000 ]
            let BlkioWeight: UInt
            
            /// A list of kernel capabilities to add to the container. Conflicts with option 'Capabilities'.
            let CapAdd: [String]?
            
            /// A list of kernel capabilities to drop from the container. Conflicts with option 'Capabilities'.
            let CapDrop: [String]?
            
            /// Cgroup to use for the container.
            let Cgroup: String
            
            // let CgroupnsMode
            
            /// Path to cgroups under which the container's cgroup is created.
            /// If the path is not absolute, the path is considered to be relative to the cgroups path of the init process.
            /// Cgroups are created if they do not already exist.
            let CgroupParent: String
            
            /// Path to a file where the container ID is written
            let ContainerIDFile: String?
            
            /// The length of a CPU period in microseconds.
            let CpuPeriod: UInt64
            
            /// Microseconds of CPU time that the container can get in a CPU period.
            let CpuQuota: UInt64
            
            /// The length of a CPU real-time period in microseconds. Set to 0 to allocate no time allocated to real-time tasks.
            let CpuRealtimePeriod: UInt64
            
            /// The length of a CPU real-time runtime in microseconds. Set to 0 to allocate no time allocated to real-time tasks.
            let CpuRealtimeRuntime: UInt64
            
            /// CPUs in which to allow execution (e.g., `0-3`, `0,1`).
            let CpusetCpus: String
            
            /// Memory nodes (MEMs) in which to allow execution (`0-3`, `0,1`). Only effective on NUMA systems.
            let CpusetMems: String
            
            /// Value representing this container's relative CPU weight versus other containers.
            let CpuShares: UInt
            
            let Devices: [DeviceMapping]?
            
            /// A list of cgroup rules to apply to the container
            let DeviceCgroupRules: [String]?
            
            /// A list of DNS servers for the container to use.
            let Dns: [String]?
            
            /// A list of DNS options.
            let DnsOptions: [String]?
            
            /// A list of DNS search domains.
            let DnsSearch: [String]?
            
            /// A list of hostnames/IP mappings to add to the container's /etc/hosts file. Specified in the form `["hostname:IP"]`.
            let ExtraHosts: [String]?
            
            /// A list of additional groups that the container process will run as.
            let GroupAdd: [String]?
            
            /// Run an init inside the container that forwards signals and reaps processes.
            /// This field is omitted if empty, and the default (as configured on the daemon) is used.
            let Init: Bool?
            
            /// IPC sharing mode for the container. Possible values are:
            /// - `none`: own private IPC namespace, with /dev/shm not mounted
            /// - `private`: own private IPC namespace
            /// - `shareable`: own private IPC namespace, with a possibility to share it with other containers
            /// - `container:<name|id>`: join another (shareable) container's IPC namespace
            /// - `host`: use the host system's IPC namespace
            /// If not specified, daemon default is used, which can either be `private` or `shareable`, depending on daemon version and configuration.
            let IpcMode: String?
            
            /// Kernel memory limit in bytes.
            /// **Deprecated**: This field is deprecated as the kernel 5.4 deprecated `kmem.limit_in_bytes`.
            @available(*, deprecated)
            let KernelMemory: UInt64
            
            /// Hard limit for kernel TCP buffer memory (in bytes).
            let KernelMemoryTCP: UInt64
            
            /// A list of links for the container in the form `container_name:alias`.
            let Links: [String]?
            
            // let LogConfig
            
            /// The list of paths to be masked inside the container (this overrides the default set of paths).
            let MaskedPaths: [String]
            
            /// Memory limit in bytes.
            let Memory: UInt64
            
            /// Memory soft limit in bytes.
            let MemoryReservation: UInt64
            
            /// Total memory limit (memory + swap). Set as -1 to enable unlimited swap.
            let MemorySwap: UInt64
            
            /// Tune a container's memory swappiness behavior. Accepts an integer between 0 and 100.
            let MemorySwappiness: UInt8?
            
            /// Specification for mounts to be added to the container.
            let Mounts: [Mount]?
            
            /// CPU quota in units of 10^-9 CPUs.
            let NanoCpus: UInt64
            
            /// Network mode to use for this container. Supported standard values are: bridge, host, none, and container:<name|id>. Any other value is taken as a custom network's name to which this container should connect to.
            let NetworkMode: String
            
            /// Disable OOM Killer for the container.
            let OomKillDisable: Bool
            
            /// An integer value containing the score given to the container in order to tune OOM killer preferences.
            let OomScoreAdj: Int
            
            /// Tune a container's PIDs limit. Set `0` or `-1` for unlimited, or `null to not change.
            let PidsLimit: UInt64?
            
            /// Set the PID (Process) Namespace mode for the container. It can be either:
            /// - `container:<name|id>`: joins another container's PID namespace
            /// - `host`: use the host's PID namespace inside the container
            let PidMode: String
            
            // let PortBindings
            
            /// Gives the container full access to the host.
            let Privileged: Bool
            
            /// Allocates an ephemeral host port for all of a container's exposed ports.
            /// Ports are de-allocated when the container stops and allocated when the container starts. The allocated port might be changed when restarting the container.
            /// The port is selected from the ephemeral port range that depends on the kernel. For example, on Linux the range is defined by `/proc/sys/net/ipv4/ip_local_port_range`.
            let PublishAllPorts: Bool
            
            /// The list of paths to be set as read-only inside the container (this overrides the default set of paths).
            let ReadonlyPaths: [String]
            
            /// Mount the container's root filesystem as read only.
            let ReadonlyRootfs: Bool
            
            // let RestartPolicy
            
            /// Runtime to use with this container.
            let Runtime: String?
            
            /// A list of string values to customize labels for MLS systems, such as SELinux.
            let SecurityOpt: [String]?
            
            /// Size of `/dev/shm` in bytes. If omitted, the system uses 64MB.
            let ShmSize: UInt
            
            /// Storage driver options for this container, in the form `{"size": "120G"}`.
            let StorageOpt: [String:String]?
            
            // let Sysctls
            
            /// A map of container directories which should be replaced by tmpfs mounts, and their corresponding mount options. For example:
            /// `{ "/run": "rw,noexec,nosuid,size=65536k" }`
            let Tmpfs: [String:String]?
            
            let Ulimits: [Ulimit]?
            
            /// Sets the usernamespace mode for the container when usernamespace remapping option is enabled.
            let UsernsMode: String
            
            /// UTS namespace to use for the container.
            let UTSMode: String
            
            
        }
    }
}
