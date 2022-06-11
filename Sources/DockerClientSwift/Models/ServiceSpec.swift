import Foundation

public struct ServiceSpec: Codable {
    public var name: String
    public var labels: [String:String] = [:]
    public var taskTemplate: TaskTemplate
    public var mode: Mode
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case labels = "Labels"
        case taskTemplate = "TaskTemplate"
        case mode = "Mode"
    }
    
    public struct TaskTemplate: Codable {
        public var containerSpec: ContainerSpec
        public var forceUpdate: UInt
        public var runtime: String = ""
        
        enum CodingKeys: String, CodingKey {
            case containerSpec = "ContainerSpec"
            case forceUpdate = "ForceUpdate"
            case runtime = "Runtime"
        }
    }
    
    public struct Mode: Codable {
        
    }
    
    public struct ContainerSpec: Codable {
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
        
        // TODO: implement
        // public var mounts: [Mount]?
        
        /// Signal to be sent to the container for stopping it.
        public var stopSignal: ContainerConfig.StopSignal? = .quit
        
        public var stopGracePeriod: UInt64? = 0
        
        public var healthCheck: ContainerConfig.HealthCheckConfig?
        
        // TODO: Implement
        //public var dnsConfig: DNSConfig
        
        // public var Secrets: [Secret]
        
        // public var Configs: [Config]?
        
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
            // case mounts = "Mounts"
            case stopSignal = "StopSignal"
            case stopGracePeriod = "StopGracePeriod"
            case healthCheck = "HealthCheck"
            // case dnsConfig = "DNSConfig"
            case `init` = "Init"
            case sysctls = "Sysctls"
            case capabilityAdd = "CapabilityAdd"
            case capabilityDrop = "CapabilityDrop"
            case ulimits = "Ulimits"
        }
        
        public struct Privileges: Codable {
            public var credentialSpec: CredentialSpec?
            public var seLinuxContext: SELinuxContext?
            
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
                
                enum CodingKeys: String, CodingKey {
                    case disable = "Disable"
                    case user = "User"
                    case role = "Role"
                    case type = "Type"
                    case level = "Level"
                }
            }
        }
    }
}
