import Foundation

public struct DockerLogEntry: Codable {
    public let source: Source
    
    /// Only set if the logs are read with the `timestamp` option set to `true`
    public let timestamp: Date?
    
    /// Optional labels when reading logs for a Service
    //public let labels: [String:String] = [:]
    
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
