import Foundation

public struct DockerLogEntry: Codable {
    public let source: Source
    public let timestamp: Date
    public let message: String
    public var eof: Bool = false
    
    public enum Source: String, Codable {
        case stdout, stderr
    }
}

enum DockerLogDecodingError: Error {
    case dataCorrupted
    case timestampCorrupted
    case noTimestampFound
    case noMessageFound
}
