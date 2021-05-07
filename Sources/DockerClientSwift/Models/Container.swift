import Foundation

/// Representation of a container.
/// Some actions can be performed on an instance.
public struct Container {
    public var id: Identifier<Container>
    public var image: Image
    public var createdAt: Date
    public var names: [String]
    public var state: String
    public var command: String
}

extension Container: Codable {}
