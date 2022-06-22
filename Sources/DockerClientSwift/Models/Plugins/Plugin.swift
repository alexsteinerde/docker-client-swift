import Foundation

// MARK: - Plugin
public struct Plugin{ Codable {
    
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
            case mounts = "mounts"
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
            public let settable: [String]
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
        
        public let documentation: String
        
        /// The interface between Docker and the plugin
        public let interface: Interface
        
        public let entryPoint: [String]
        
        public let workDir: String
        
        public let user: User
        
        public let network: NetworkType
        
        enum CodingKeys: String, CodingKey {
            case dockerVersion = "DockerVersion"
            case description = "Description"
            case documentation = "Documentation"
            case interface = "Interface"
            case entryPoint = "EntryPoint"
            case workDir = "WorkDir"
            case user = "User"
        }
        
        public struct Interface: Codable {
            public let types: [PluginInterfaceType]
            
            public let socket: String
            
            /// Protocol to use for clients connecting to the plugin.
            /// Valid values: "" and "moby.plugins.http/v1"
            public let protocolScheme: String
            
            enum CodingKeys: String, CodingKey {
                case types = "types"
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
        }
        
        public struct User: Codable {
            public let uid: UInt64
            public let gid: UInt64
            
            enum CodingKeys: String, CodingKey {
                case uid = "UID"
                case gid = "GID"
            }
        }
        
        public struct NetworkType: Codable {
            public let `type`: String
            
            enum CodingKeys: String, CodingKey {
                case `type` = "Type"
            }
        }
    }
    
}
