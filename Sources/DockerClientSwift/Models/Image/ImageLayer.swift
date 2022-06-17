import Foundation
import BetterCodable

/// Information about an `Image` layer returned by the image History endpoint.
public struct ImageLayer: Codable {
    public let id: String
    
    @DateValue<TimestampStrategy>
    private(set) public var createdAt: Date
    
    /// Dockerfile step that generated this layer
    public let createdBy: String
    
    public let tags: [String]
    
    /// Size of this layer, in bytes
    public let size: UInt64
    
    public let comment: String
}
