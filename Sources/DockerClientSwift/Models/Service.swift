import Foundation

/// Representation of a service.
/// Some actions can be performed on an instance.
public struct Service {
    public let id: Identifier<Service>
    public let name: String
    public let createdAt: Date?
    public let updatedAt: Date?
    public var version: Int
    public var image: Image
}

extension Service: Codable {}
