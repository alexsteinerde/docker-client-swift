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
    public let hostConfig: ContainerHostConfig
    
    /// The time the container was created
    public let createdAt: Date
    
    /// The storage driver used to store the container's and image's filesystem.
    public let storageDriver: String
    
    public let execIDs: [String]?
    
    public let graphDriver: GraphDriver
    
    public let hostnamePath: String
    public let hostsPath: String
    
    /// The ID of the container
    public let id: String
    
    /// The container's image ID
    public let image: String
    
    public let logPath: String
    
    public let mountLabel: String
    
    public let mounts: [ContainerMountPoint]
    
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
        case graphDriver = "GraphDriver"
        case hostConfig = "HostConfig"
        case hostnamePath = "HostnamePath"
        case hostsPath = "HostsPath"
        case id = "Id"
        case image = "Image"
        case logPath = "LogPath"
        case mountLabel = "MountLabel"
        case mounts = "Mounts"
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
    
    public enum ContainerMountType: String, Codable {
        case bind, volume, tmpft, npipe
    }
    
    public struct ContainerMountPoint: Codable {
        public let type: ContainerMountType
        
        /// Volume name.
        public let name: String
        
        /// Source location of the mount.
        /// For volumes, this contains the storage location of the volume (within /var/lib/docker/volumes/).
        /// For bind-mounts, and npipe, this contains the source (host) part of the bind-mount.
        ///  For tmpfs mount points, this field is empty.
        public let source: String
        
        /// Path relative to the container root (/) where the `source` is mounted inside the container.
        public let destination: String
        
        /// Volume driver used to create the volume (if it is a volume).
        public let driver: String
        
        /// Comma separated list of options supplied by the user when creating the bind/volume mount.
        /// The default is platform-specific ("z" on Linux, empty on Windows).
        public let mode: String
        
        /// Whether the mount is mounted writable (read-write).
        public let rw: Bool
        
        /// Describes how mounts are propagated from the host into the mount point, and vice-versa.
        /// Refer to the Linux kernel documentation for details. This field is not used on Windows.
        public let propagation: String
        
        enum CodingKeys: String, CodingKey {
            case type = "Type"
            case name = "Name"
            case source = "Source"
            case destination = "Destination"
            case driver = "Driver"
            case mode = "Mode"
            case rw = "RW"
            case propagation = "Propagation"
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
        
        // TODO: fix parsing these inconsistent dates (different format when set and not set)
        /// The time when this container was last started.
        //@DateValue<ISO8601Strategy>
        //private(set)public var startedAt: Date
        
        /// The time when this container last exited.
        //@DateValue<ISO8601Strategy>
        //private(set)public var finishedAt: Date
        
        /// The state of this container (e.g. `exited`)
        public let status: State
        
        enum CodingKeys: String, CodingKey {
            case dead = "Dead"
            case error = "Error"
            case exitCode = "ExitCode"
            case health = "Health"
            //case finishedAt = "FinishedAt"
            case oomKilled = "OOMKilled"
            case paused = "Paused"
            case pid = "Pid"
            case running = "Running"
            case restarting = "Restarting"
            //case startedAt = "StartedAt"
            case status = "Status"
        }
        
        public enum State: String, Codable {
            case created, restarting, running, removing, paused, exited, dead
        }
    }
    
    public struct GraphDriver: Codable {
        /// Name of the storage driver.
        public let name: String
        /// Low-level storage metadata, provided as key/value pairs.
        public let data: [String:String]?
        
        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case data = "Data"
        }
    }
}
