import Foundation
import BetterCodable

/// Details about a Docker volume
public struct Volume: Codable {
    /// Name of the volume.
    public let name: String
    
    /// Name of the volume driver used by the volume.
    public let driver: String
    
    /// Mount path of the volume on the host.
    public let mountPoint: String
    
    /// Date/Time the volume was created.
    @DateValue<ISO8601Strategy>
    private(set) public var createdAt: Date
    
    /// Low-level details about the volume, provided by the volume driver.
    public let status: [String:String]?
    
    /// User-defined key/value metadata.
    public let labels: [String:String]?
    
    /// The level at which the volume exists
    public let scope: DockerScope
    
    /// The driver specific options used when creating the volume.
    public let driverOptions: [String:String]?
    
    /// Usage details about the volume. This information is used by the GET /system/df endpoint, and omitted in other endpoints.
    public let usageData: UsageData?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case driver = "Driver"
        case mountPoint = "Mountpoint"
        case createdAt = "CreatedAt"
        case status = "Status"
        case labels = "Labels"
        case scope = "Scope"
        case driverOptions = "Options"
        case usageData = "UsageData"
    }
    
    public struct UsageData: Codable {
        /// Amount of disk space used by the volume (in bytes). This information is only available for volumes created with the "local" volume driver. For volumes created with other volume drivers, this field is set to -1 ("not available")
        public let size: UInt64
        
        /// The number of containers referencing this volume. This field is set to -1 if the reference-count is not available.
        public let refCount: Int
        
        enum CodingKeys: String, CodingKey {
            case size = "Size"
            case refCount = "RefCount"
        }
    }
}
