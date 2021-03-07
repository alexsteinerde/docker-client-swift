import Foundation

public struct Container {
    public var id: Identifier<Container>
    public var image: Image
    public var createdAt: Date
    public var names: [String]
    public var state: String
    public var command: String
}
