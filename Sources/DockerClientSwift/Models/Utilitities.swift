import Foundation

public struct MessageResponse: Codable {
    let message: String
}

/// Representation of an image digest.
/*public struct Digest {
    public var rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Digest: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}*/

extension Digest: Codable {}

public enum DockerError: Error {
    /// Not connected to an Attach/Exec endpoint, or disconnected
    case notconnected
    /// Custom error from the Docker daemon
    case message(String)
    case unknownResponse(String)
    case corruptedData(String)
    case errorCode(Int, String?)
    case unsupportedScheme(String)
}

