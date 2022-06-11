import Foundation

public struct DockerLogEntry: Codable {
    public let source: Source
    
    /// Only set if the logs are read witb the `timestamp` option set to `true`
    public let timestamp: Date?
    
    public let message: String
    
    public enum Source: UInt8, Codable {
        case stdin = 0
        case stdout = 1
        case stderr = 2
    }
}

enum DockerLogDecodingError: Error {
    case dataCorrupted(_ message: String)
    case timestampCorrupted
    case noTimestampFound
    case noMessageFound
}
