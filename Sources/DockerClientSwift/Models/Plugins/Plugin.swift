import Foundation

// MARK: - Plugin
public struct Plugin: Codable {
    
    public let id: String
    
    /// The name of the plugin
    public let name: String
    
    /// `true` if the plugin is running. `false` if the plugin is not running, only installed.
    public let enabled: Bool
    
    /// Settings that can be modified by users.
    public let settings: Settings
    
    /// The  remote reference used to push/pull the plugin
    public let pluginReference: String
    
    /// The config of a plugin.
    public let config: Config
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case enabled = "Enabled"
        case settings = "Settings"
        case pluginReference = "PluginReference"
        case config = "Config"
    }
    
    // MARK: - Settings
    public struct Settings: Codable {
        public let mounts: [PluginMount]
        public let environmentVars: [String]
        public let arguments: [String]
        public let devices: [PluginDevice]
        
        enum CodingKeys: String, CodingKey {
            case mounts = "Mounts"
            case environmentVars = "Env"
            case arguments = "Args"
            case devices = "Devices"
        }
        
        public struct PluginMount: Codable {
            public let name: String
            public let description: String
            public let settable: [String]
            public let source: String
            public let destination: String
            public let `type`: String
            public let options: [String]
            
            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case description = "Description"
                case settable = "Settable"
                case source = "Source"
                case destination = "Destination"
                case `type` = "Type"
                case options = "Options"
            }
        }
        
        public struct PluginDevice: Codable {
            public let name: String
            public let description: String
            public let settable: [String]?
            public let path: String
            
            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case description = "Description"
                case settable = "Settable"
                case path = "Path"
            }
        }
    }
    
    // MARK: - Config
    public struct Config: Codable {
        /// Docker Version used to create the plugin
        public let dockerVersion: String
        
        public let description: String
        
        /// Link to the documentation about the plugin.
        public let documentation: String
        
        /// The interface between Docker and the plugin
        public let interface: Interface
        
        /// Entrypoint of the plugin, see Dockerfile `ENTRYPOINT`.
        public let entryPoint: [String]?
        
        /// Workdir of the plugin, see Dockerfile `WORKDIR`.
        public let workDir: String
        
        public let user: User
        
        public let network: NetworkType
        
        public let linux: Linux
        
        /// Path to be mounted as `rshared`, so that mounts under that path are visible to Docker. This is useful for volume plugins.
        /// This path will be bind-mounted outside of the plugin rootfs so it’s contents are preserved on upgrade.
        public let propagatedMount: String
        
        /// Access to host ipc namespace
        public let ipcHost: Bool
        
        /// Access to host pid namespace.
        public let pidHost: Bool
        
        public let mounts: [Settings.PluginMount]
        
        /// Environment variables of the plugin.
        public let environmentVars: [PluginEnv]
        
        /// Args of the plugin
        public let arguments: PluginArg
        
        public let rootFs: RootFS
        
        enum CodingKeys: String, CodingKey {
            case dockerVersion = "DockerVersion"
            case description = "Description"
            case documentation = "Documentation"
            case interface = "Interface"
            case entryPoint = "EntryPoint"
            case workDir = "WorkDir"
            case user = "User"
            case network = "Network"
            case linux = "Linux"
            case propagatedMount = "PropagatedMount"
            case ipcHost = "IpcHost"
            case pidHost = "PidHost"
            case mounts = "Mounts"
            case environmentVars = "Env"
            case arguments = "Args"
            case rootFs = "rootfs"
        }
        
        // MARK: - Interface
        public struct Interface: Codable {
            /// The kinds of Docker plugins that the plugin provides.
            public let types: [PluginType]
            
            /// Name of the socket the engine should use to communicate with the plugins. the socket will be created in `/run/docker/plugins`.
            public let socket: String
            
            /// Protocol to use for clients connecting to the plugin.
            /// Valid values: "" and "moby.plugins.http/v1"
            public let protocolScheme: String?
            
            enum CodingKeys: String, CodingKey {
                case types = "Types"
                case socket = "Socket"
                case protocolScheme = "ProtocolScheme"
            }
            
            public struct PluginInterfaceType: Codable {
                public let prefix: String
                public let capability: String
                public let version: String
                
                enum CodingKeys: String, CodingKey {
                    case prefix = "Prefix"
                    case capability = "Capability"
                    case version = "Version"
                }
            }
            
            public enum PluginType: String, Codable {
                /// Docker storage/volume plugin
                case volume = "docker.volumedriver/1.0"
                /// Docker networking plugin
                case network = "docker.networkdriver/1.0"
                /// Docker IPAM (IP addresses Management) plugin
                case ipam = "docker.ipamdriver/1.0"
                /// Docker authorization plugin
                case authz = "docker.authz/1.0"
                /// Docker log driver
                case logs = "docker.logdriver/1.0"
                /// Docker metrics plugin
                case metrics = "docker.metricscollector/1.0"
            }
        }
        
        // MARK: - User
        public struct User: Codable {
            public let uid: UInt64?
            public let gid: UInt64?
            
            enum CodingKeys: String, CodingKey {
                case uid = "UID"
                case gid = "GID"
            }
        }
        
        // MARK: - NetworkType
        public struct NetworkType: Codable {
            /// Network type used by the Plugn.
            public let `type`: NetworkType
            
            enum CodingKeys: String, CodingKey {
                case `type` = "Type"
            }
            
            public enum NetworkType: String, Codable {
                case none, bridge, host
            }
        }
        
        // MARK: - Linux
        public struct Linux: Codable {
            /// Capabilities required by the plugin (Linux only)
            public let capabilities: [String]
            
            /// If /dev is bind mounted from the host, and allowAllDevices is set to true, the plugin will have rwm access to all devices on the host.
            public let allowAllDevices: Bool
            
            public let devices: [Settings.PluginDevice]
            
            enum CodingKeys: String, CodingKey {
                case capabilities = "Capabilities"
                case allowAllDevices = "AllowAllDevices"
                case devices = "Devices"
            }
        }
        
        // MARK: - PluginEnv
        public struct PluginEnv: Codable {
            public let name: String
            public let description: String
            public let settable: [String]
            public let value: String
            
            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case description = "Description"
                case settable = "Settable"
                case value = "Value"
            }
        }
        
        // MARK: - PluginArg
        public struct PluginArg: Codable {
            public let name: String
            public let description: String
            public let settable: [String]?
            public let value: [String]?
            
            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case description = "Description"
                case settable = "Settable"
                case value = "Value"
            }
        }
        
        // MARK: - RootFS
        public struct RootFS: Codable {
            public let type: String
            public let diff_ids: [String]
            
        }
    }
    
}
