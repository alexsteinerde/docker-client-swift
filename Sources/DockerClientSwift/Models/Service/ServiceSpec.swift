import Foundation

// MARK: - ServiceSpec
public struct ServiceSpec: Codable {
    public init(name: String, labels: [String : String] = [:], taskTemplate: ServiceSpec.TaskTemplate, mode: ServiceSpec.ServiceMode = .replicated(1), updateConfig: ServiceSpec.UpdateOrRollbackConfig? = nil, rollbackConfig: ServiceSpec.UpdateOrRollbackConfig? = nil, networks: [ServiceSpec.NetworkAttachmentConfig]? = nil, endpointSpec: ServiceEndpointSpec? = nil) {
        self.name = name
        self.labels = labels
        self.taskTemplate = taskTemplate
        self.mode = mode
        self.updateConfig = updateConfig
        self.rollbackConfig = rollbackConfig
        self.networks = networks
        self.endpointSpec = endpointSpec
    }
    
    /// Name of the service.
    public var name: String
    
    /// User-defined key/value metadata.
    public var labels: [String:String] = [:]
    
    /// User modifiable task configuration.
    public var taskTemplate: TaskTemplate
    
    /// Scheduling mode for the service.
    public var mode: ServiceMode = .replicated(1)
    
    public var updateConfig: UpdateOrRollbackConfig?
    
    public var rollbackConfig: UpdateOrRollbackConfig?
    
    /// Configuration for the networks this service belongs to.
    public var networks: [NetworkAttachmentConfig]?
    
    /// Configuration for the ports publshed by this service.
    public var endpointSpec: ServiceEndpointSpec?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case labels = "Labels"
        case taskTemplate = "TaskTemplate"
        case mode = "Mode"
        case updateConfig = "UpdateConfig"
        case rollbackConfig = "RollbackConfig"
        case networks = "Networks"
        case endpointSpec = "EndpointSpec"
    }
    
    // MARK: - TaskTemplate
    /// Note: `containerSpec`, `networkAttachmentSpec`, and `pluginSpec` are mutually exclusive.
    /// `pluginSpec` is only used when the `runtime` field is set to `plugin`. `networkAttachmentSpec` is used when the `runtime` field is set to `attachment`.
    public struct TaskTemplate: Codable {
        public init(containerSpec: ServiceSpec.ContainerSpec, forceUpdate: UInt? = nil, runtime: ServiceSpec.TaskTemplate.Runtime? = .container, resources: ServiceSpec.TaskTemplate.Resources? = nil, restartPolicy: ServiceRestartPolicy? = nil, networks: [ServiceSpec.NetworkAttachmentConfig]? = nil, logDriver: DriverConfig? = nil) {
            self.containerSpec = containerSpec
            self.forceUpdate = forceUpdate
            self.runtime = runtime
            self.resources = resources
            self.restartPolicy = restartPolicy
            self.networks = networks
            self.logDriver = logDriver
        }
        
        
        /// Onyl used when the Runtime field is set to attachment.
        // public var NetworkAttachmentSpec
        /// Only used when the Runtime field is set to plugin.
        // public var PluginSpec
        
        public var containerSpec: ContainerSpec
        
        /// A counter that triggers an update even if no relevant parameters have been changed.
        public var forceUpdate: UInt?
        
        /// The type of runtime specified for the task executor.
        /// Can be `nil` when listing `SwarmTask`s.
        public var runtime: Runtime? = .container
        
        public var resources: Resources?
        
        /// Specification for the restart policy which applies to containers created as part of this service.
        public var restartPolicy: ServiceRestartPolicy?
        
        // TODO: implement
        //public var placement: Placement
        
        /// Specifies which networks the service should attach to.
        public var networks: [NetworkAttachmentConfig]?
        
        /// Specifies the log driver to use for tasks created from this spec.
        /// If not present, the default one for the swarm will be used, finally falling back to the engine default if not specified.
        public var logDriver: DriverConfig?
        
        enum CodingKeys: String, CodingKey {
            case containerSpec = "ContainerSpec"
            case forceUpdate = "ForceUpdate"
            case runtime = "Runtime"
            case resources = "Resources"
            case restartPolicy = "RestartPolicy"
            case logDriver = "LogDriver"
            case networks = "Networks"
        }
        
        public enum Runtime: String, Codable {
            case attachment, container, plugin
        }
        
        // MARK: - Resource
        public struct Resources: Codable {
            internal init(limits: ServiceSpec.TaskTemplate.Resources.Limit? = nil, reservations: ServiceSpec.TaskTemplate.Resources.ResourceObject? = nil) {
                self.limits = limits
                self.reservations = reservations
            }
            
            public var limits: Limit? = nil
            public var reservations: ResourceObject? = nil
            
            enum CodingKeys: String, CodingKey {
                case limits = "Limits"
                case reservations = "Reservations"
            }
            
            public struct Limit: Codable {
                public init(nanoCPUs: UInt64? = 0, memoryBytes: UInt64? = 0, pids: UInt64? = 0) {
                    self.nanoCPUs = nanoCPUs
                    self.memoryBytes = memoryBytes
                    self.pids = pids
                }
                
            
                public var nanoCPUs: UInt64? = 0
                
                public var memoryBytes: UInt64? = 0
                
                /// Limits the maximum number of PIDs in the container. Set 0 for unlimited.
                public var pids: UInt64? = 0
                
                enum CodingKeys: String, CodingKey {
                    case nanoCPUs = "NanoCPUs"
                    case memoryBytes = "MemoryBytes"
                    case pids = "Pids"
                }
            }
            
            public struct ResourceObject: Codable {
                public init(nanoCPUs: UInt64? = 0, memoryBytes: UInt64? = 0, genericResources: [GenericResource]? = []) {
                    self.nanoCPUs = nanoCPUs
                    self.memoryBytes = memoryBytes
                    self.genericResources = genericResources
                }
                
                public var nanoCPUs: UInt64? = 0
                
                public var memoryBytes: UInt64? = 0
                
                public var genericResources: [GenericResource]? = []
                
                enum CodingKeys: String, CodingKey {
                    case nanoCPUs = "NanoCPUs"
                    case memoryBytes = "MemoryBytes"
                    case genericResources = "GenericResources"
                }
            }
        }
    }
    
    // MARK: - NetworkAttachmentConfig
    public struct NetworkAttachmentConfig: Codable {
        public init(target: String, aliases: [String]? = [], driverOpts: [String : String]? = [:]) {
            self.target = target
            self.aliases = aliases
            self.driverOpts = driverOpts
        }
        
        /// The target network for attachment. Must be a network name or ID.
        public var target: String
        
        /// Discoverable alternate names for the service on this network.
        public var aliases: [String]? = []
        
        /// Driver attachment options for the network target.
        public var driverOpts: [String:String]? = [:]
        
        enum CodingKeys: String, CodingKey {
            case target = "Target"
            case aliases = "Aliases"
            case driverOpts = "DriverOpts"
        }
    }
    
    // MARK: - ServiceMode
    /// Scheduling mode for a Docker service.
    public struct ServiceMode: Codable {
        /// A service that can have one or many instances (replicas) expected to run permanently.
        private(set) public var replicated: Replicated?
        
        /// A service with a finite number of tasks that run to a completed state.
        private(set) public var replicatedJob: ReplicatedJob? = nil
        
        /// Run a “one-off” job  globally which means each node in the cluster will run a task for this job
        private(set) public var GlobalJob: GlobalJob? = nil
        
        /// A service with one task per node that run until reaching a completed state.
        private(set) public var Global: Global? = nil
        
        enum CodingKeys: String, CodingKey {
            case replicated = "Replicated"
            case replicatedJob = "ReplicatedJob"
        }
        
        public struct Replicated: Codable {
            /// The maximum number of replicas to run simultaneously.
            public var replicas: UInt32
            
            enum CodingKeys: String, CodingKey {
                case replicas = "Replicas"
            }
        }
        
        // A global service that runs one instance on each Swarm node.
        public struct Global: Codable {}
        
        // A global service that runs a configurable number of instances.
        public struct ReplicatedJob: Codable {
            /// The maximum number of replicas to run simultaneously.
            public var maxConcurrent: UInt = 1
            
            /// The total number of replicas desired to reach the Completed state.
            /// If unset, will default to the value of MaxConcurrent
            public var totalCompletions: UInt?
            
            enum CodingKeys: String, CodingKey {
                case maxConcurrent = "MaxConcurrent"
                case totalCompletions = "TotalCompletions"
            }
        }
        
        public struct GlobalJob: Codable {}
        
        /// Create a service having one task per Swarm.
        public static func global() -> ServiceMode {
            return ServiceMode(global: .init())
        }
        
        /// Create a classical Service that can have multiple replicas.
        /// - Parameters:
        ///   - replicas: Desired number of replicas (containers) to run.
        public static func replicated(_ replicas: UInt32) -> ServiceMode {
            return ServiceMode(replicated: .init(replicas: replicas))
        }
        
        /// Create a Job that runs one task per Swarm node.
        /// Unlike a service which is expected to run continuously, a Job's task containers are expected to exit when their work is finished.
        public static func globalJob() -> ServiceMode {
            return ServiceMode(global: .init())
        }
        
        /// Create a Job that runs a specified number of one-off tasks.
        /// Unlike a service which is expected to run continuously, a Job's task containers are expected to exit when their work is finished.
        /// - Parameters:
        ///   - maxConcurrent: The maximum number of replicas (containers) to run simultaneously.
        ///   - totalCompletions: The total number of replicas desired to reach the Completed state. If unset, will default to the value of `maxConcurrent`
        public static func job(_ maxConcurrent: UInt, totalCompletions: UInt? = nil) -> ServiceMode {
            return ServiceMode(replicatedJob: .init(maxConcurrent: maxConcurrent, totalCompletions: totalCompletions))
        }
        
        private init(replicated: ServiceSpec.ServiceMode.Replicated? = nil, replicatedJob: ServiceSpec.ServiceMode.ReplicatedJob? = nil, global: Global? = nil) {
            self.replicated = replicated
            self.replicatedJob = replicatedJob
        }
        
        private init(){}
    }
    
    // MARK: - UpdateOrRollbaclConfig
    public struct UpdateOrRollbackConfig: Codable {
        public init(parallelism: UInt64, delay: UInt64? = nil, failureAction: ServiceSpec.UpdateOrRollbackConfig.FailureAction, monitor: UInt64, maxFailureRatio: Float = 0, order: ServiceSpec.UpdateRollBackOrder) {
            self.parallelism = parallelism
            self.delay = delay
            self.failureAction = failureAction
            self.monitor = monitor
            self.maxFailureRatio = maxFailureRatio
            self.order = order
        }
        
        /// Maximum number of tasks to be updated in one iteration (0 means unlimited parallelism).
        public var parallelism: UInt64
        
        /// Amount of time between updates, in nanoseconds.
        public var delay: UInt64?
        
        /// Action to take if an updated task fails to run, or stops running during the update.
        public var failureAction: FailureAction
        
        /// Amount of time to monitor each updated task for failures, in nanoseconds.
        public var monitor: UInt64
        
        /// The fraction of tasks that may fail during an update before the failure action is invoked, specified as a floating point number between 0 and 1.
        public var maxFailureRatio: Float = 0
        
        public var order: UpdateRollBackOrder
        
        enum CodingKeys: String, CodingKey {
            case parallelism = "Parallelism"
            case delay = "Delay"
            case failureAction = "FailureAction"
            case monitor = "Monitor"
            case maxFailureRatio = "MaxFailureRatio"
            case order = "Order"
        }
        
        public enum FailureAction: String, Codable {
            case `continue`, pause, rollback
        }
    }
    
    public enum UpdateRollBackOrder: String, Codable {
        /// the old task is shut down before the new task is started
        case stopFirst = "stop-first"
        /// the new task is started before the old task is shut down
        case startFirst = "start-first"
    }
    
    // MARK: - ContainerSpec
    public struct ContainerSpec: Codable {
        public init(image: String, isolation: String = "default", labels: [String : String]? = [:], command: [String]? = [], args: [String]? = [], hostname: String? = nil, env: [String]? = [], workDir: String? = nil, user: String? = nil, groups: [String]? = nil, privileges: ServiceSpec.ContainerSpec.Privileges? = nil, tty: Bool? = false, openStdin: Bool? = false, readOnly: Bool? = false, mounts: [ContainerHostConfig.ContainerMount]? = nil, stopSignal: ContainerConfig.StopSignal? = .quit, stopGracePeriod: UInt64? = 0, healthCheck: ContainerConfig.HealthCheckConfig? = nil, dnsConfig: ServiceSpec.ContainerSpec.DNSConfig? = .init(), secrets: [ServiceSpec.ContainerSpec.Secret]? = [], configs: [ServiceSpec.ContainerSpec.Config]? = [], init: Bool? = nil, sysctls: [String : String]? = [:], capabilityAdd: [String]? = [], capabilityDrop: [String]? = [], ulimits: [ContainerHostConfig.Ulimit]? = []) {
            self.image = image
            self.isolation = isolation
            self.labels = labels
            self.command = command
            self.args = args
            self.hostname = hostname
            self.env = env
            self.workDir = workDir
            self.user = user
            self.groups = groups
            self.privileges = privileges
            self.tty = tty
            self.openStdin = openStdin
            self.readOnly = readOnly
            self.mounts = mounts
            self.stopSignal = stopSignal
            self.stopGracePeriod = stopGracePeriod
            self.healthCheck = healthCheck
            self.dnsConfig = dnsConfig
            self.secrets = secrets
            self.configs = configs
            self.`init` = `init`
            self.sysctls = sysctls
            self.capabilityAdd = capabilityAdd
            self.capabilityDrop = capabilityDrop
            self.ulimits = ulimits
        }
        
        /// The image name to use for the container
        public var image: String
        
        /// Windows only. Isolation technology of the containers running the service.
        /// Valid values: "default" "process" "hyperv"
        public var isolation: String = "default"
        
        public var labels: [String:String]? = [:]
        
        /// The command to be run in the image.
        public var command: [String]? = []
        
        /// Arguments to the command.
        public var args: [String]? = []
        
        /// The hostname to use for the container, as a valid RFC 1123 hostname.
        public var hostname: String? = nil
        
        /// A list of environment variables in the form `VAR=value`.
        public var env: [String]? = []
        
        /// The working directory for commands to run in.
        public var workDir: String? = nil
        
        /// The user inside the container.
        public var user: String? = nil
        
        /// A list of additional groups that the container process will run as.
        public var groups: [String]? = nil
        
        /// Security options for the container
        public var privileges: Privileges? = nil
        
        /// Whether a pseudo-TTY should be allocated.
        public var tty: Bool? = false
        
        /// Open stdin
        public var openStdin: Bool? = false
        
        /// Mount the container's root filesystem as read only.
        public var readOnly: Bool? = false
        
        public var mounts: [ContainerHostConfig.ContainerMount]? = nil
        
        /// Signal to be sent to the container for stopping it.
        public var stopSignal: ContainerConfig.StopSignal? = .quit
        
        public var stopGracePeriod: UInt64? = 0
        
        public var healthCheck: ContainerConfig.HealthCheckConfig?
        
        /// Specification for DNS related configurations in resolver configuration file (resolv.conf).
        public var dnsConfig: DNSConfig? = .init()
        
        public var secrets: [Secret]? = []
        
        public var configs: [Config]? = []
        
        /// Run an init inside the container that forwards signals and reaps processes.
        /// This field is omitted if empty, and the default (as configured on the daemon) is used.
        public var `init`: Bool? = nil
        
        /// Set kernel namedspaced parameters (sysctls) in the container.
        /// The Sysctls option on services accepts the same sysctls as the are supported on containers.
        /// Note that while the same sysctls are supported, no guarantees or checks are made about their suitability for a clustered environment, and it's up to the user to determine whether a given sysctl will work properly in a Service.
        public var sysctls: [String:String]? = [:]
        
        /// A list of kernel capabilities to add to the default set for the container.
        public var capabilityAdd: [String]? = []
        
        /// A list of kernel capabilities to drop from the default set for the container.
        public var capabilityDrop: [String]? = []
        
        /// A list of resource limits to set in the container.
        /// For example: {"Name": "nofile", "Soft": 1024, "Hard": 2048}"
        public var ulimits: [ContainerHostConfig.Ulimit]? = []
        
        
        enum CodingKeys: String, CodingKey {
            case image = "Image"
            case isolation = "Isolation"
            case labels = "Labels"
            case args = "Args"
            case hostname = "Hostname"
            case env = "Env"
            case workDir = "dir"
            case user = "User"
            case groups = "Groups"
            case privileges = "Privileges"
            case tty = "TTY"
            case openStdin = "OpenStdin"
            case readOnly = "ReadOnly"
            case mounts = "Mounts"
            case stopSignal = "StopSignal"
            case stopGracePeriod = "StopGracePeriod"
            case healthCheck = "HealthCheck"
            case dnsConfig = "DNSConfig"
            case configs = "Configs"
            case secrets = "Secrets"
            case `init` = "Init"
            case sysctls = "Sysctls"
            case capabilityAdd = "CapabilityAdd"
            case capabilityDrop = "CapabilityDrop"
            case ulimits = "Ulimits"
        }
        
        // MARK: - Privileges
        public struct Privileges: Codable {
            public var credentialSpec: CredentialSpec?
            public var seLinuxContext: SELinuxContext?
            
            public init(credentialSpec: ServiceSpec.ContainerSpec.Privileges.CredentialSpec? = nil, seLinuxContext: ServiceSpec.ContainerSpec.Privileges.SELinuxContext? = nil) {
                self.credentialSpec = credentialSpec
                self.seLinuxContext = seLinuxContext
            }
            
            enum CodingKeys: String, CodingKey {
                case credentialSpec = "CredentialSpec"
                case seLinuxContext = "SELinuxContext"
            }
            
            public struct CredentialSpec: Codable {
                /// Load credential spec from a Swarm Config with the given ID.
                /// The specified config must also be present in the Configs field with the Runtime property set.
                /// NOTE: mutually exlusive with `registry` and `file`
                public var config: String?
                
                /// Load credential spec from this file. The file is read by the daemon, and must be present in the CredentialSpecs subdirectory in the docker data directory
                /// NOTE: mutually exlusive with `registry` and `config`
                public var file: String?
                
                /// Windows only. Load credential spec from this value in the Windows registry.
                /// The specified registry value must be located in: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\Containers\CredentialSpecs
                /// NOTE: mutually exlusive with `file` and `config`
                public var registry: String?
                
                public init(config: String? = nil, file: String? = nil, registry: String? = nil) {
                    self.config = config
                    self.file = file
                    self.registry = registry
                }
                
                enum CodingKeys: String, CodingKey {
                    case config = "Config"
                    case file = "File"
                    case registry = "Registry"
                }
            }
            
            public struct SELinuxContext: Codable {
                public var disable: Bool?
                public var user: String?
                public var role: String?
                public var type: String?
                public var level: String?
                
                public init(disable: Bool? = nil, user: String? = nil, role: String? = nil, type: String? = nil, level: String? = nil) {
                    self.disable = disable
                    self.user = user
                    self.role = role
                    self.type = type
                    self.level = level
                }
                
                enum CodingKeys: String, CodingKey {
                    case disable = "Disable"
                    case user = "User"
                    case role = "Role"
                    case type = "Type"
                    case level = "Level"
                }
            }
        }
        
        // MARK: - DNSConfig
        public struct DNSConfig: Codable {
            /// The IP addresses of the name servers.
            public var nameservers: [String]? = []
            
            /// A search list for host-name lookup.
            public var search: [String]? = []
            
            /// A list of internal resolver variables to be modified (e.g., `debug`, `ndots:3`, etc.).
            public var options: [String]? = []
            
            public init(nameservers: [String]? = [], search: [String]? = [], options: [String]? = []) {
                self.nameservers = nameservers
                self.search = search
                self.options = options
            }
            
            enum CodingKeys: String, CodingKey {
                case nameservers = "Nameservers"
                case search = "Search"
                case options = "Options"
            }
        }
        
        public struct ConfigOrSecretFile: Codable {
            /// The final filename in the filesystem.
            public var name: String
            
            /// The file UID.
            public var uid: String = "0"
            
            /// The file GID.
            public var gid: String = "0"
            
            /// The FileMode of the file.
            public var mode: UInt32 = 0o444
            
            public init(name: String, uid: String = "0", gid: String = "0", mode: UInt32 = 0o444) {
                self.name = name
                self.uid = uid
                self.gid = gid
                self.mode = mode
            }
            
            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case uid = "UID"
                case gid = "GID"
                case mode = "Mode"
            }
        }
        
        // MARK: - Secret
        public struct Secret: Codable {
            /// Aa specific target that is backed by a file.
            public var file: ConfigOrSecretFile
            
            /// The ID of the specific Docker Secret that we're referencing.
            public var secretId: String
            
            /// SecretName is the name of the secret that this references, but this is just provided for lookup/display purposes.
            /// The secret in the reference will be identified by its ID.
            public var secretName: String
            
            public init(_ secret: DockerClientSwift.Secret) {
                self.file = .init(name: secret.spec.name)
                self.secretId = secret.id
                self.secretName = secret.spec.name
            }
            
            internal init(file: ServiceSpec.ContainerSpec.ConfigOrSecretFile, secretId: String, secretName: String) {
                self.file = file
                self.secretId = secretId
                self.secretName = secretName
            }
            
            enum CodingKeys: String, CodingKey {
                case file = "File"
                case secretId = "SecretID"
                case secretName = "SecretName"
            }
        }
        
        // MARK: - Config
        public struct Config: Codable {
            public var file: ConfigOrSecretFile?
            //public var runtime: String?
            public var configId: String
            public var configName: String
            
            public init(_ config: DockerClientSwift.Config) {
                self.file = .init(name: config.spec.name)
                self.configId = config.id
                self.configName = config.spec.name
            }
            
            public init(file: ServiceSpec.ContainerSpec.ConfigOrSecretFile? = nil, configId: String, configName: String) {
                self.file = file
                self.configId = configId
                self.configName = configName
            }
            
            enum CodingKeys: String, CodingKey {
                case file = "File"
                //case runtime = "Runtime"
                case configId = "ConfigID"
                case configName = "ConfigName"
            }
        }
    }
}
