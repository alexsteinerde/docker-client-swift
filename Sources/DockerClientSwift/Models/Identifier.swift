public struct Identifier<T> {
    public init(_ value: String) {
        self.value = value
    }

    public typealias StringLiteralType = String

    public var value: String
}

extension Identifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.value = value
    }
}

extension Identifier: Equatable { }

extension Identifier: Codable {}
