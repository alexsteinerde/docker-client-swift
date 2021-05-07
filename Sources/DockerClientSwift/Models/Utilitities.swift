import Foundation

struct Status: Codable {
    let status: String
}

public struct MessageResponse: Codable {
    let message: String
}

/// Representation of an image digest.
public struct Digest {
    public var rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Digest: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension Digest: Codable {}

public enum DockerError: Error {
    case message(String)
    case unknownResponse(String)
    case errorCode(Int, String?)
}

