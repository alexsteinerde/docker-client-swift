import Foundation

public struct ServiceRestartPolicy: Codable {
    /// Condition for restart.
    let condition: ServiceRestartCondition
    
    /// Delay between restart attempts.
    let delay: UInt64
    
    /// Maximum attempts to restart a given container before giving up (default value is 0, which is ignored).
    let maxAttempts: UInt64
    
    /// Time window used to evaluate the restart policy (default value is 0, which is unbounded).
    let window: UInt64? = 0
    
    public init(condition: ServiceRestartPolicy.ServiceRestartCondition = .onFailure, delay: UInt64, maxAttempts: UInt64) {
        self.condition = condition
        self.delay = delay
        self.maxAttempts = maxAttempts
    }
    
    enum CodingKeys: String, CodingKey {
        case condition = "Condition"
        case delay = "Delay"
        case maxAttempts = "MaxAttempts"
        case window = "Window"
    }
    
    public enum ServiceRestartCondition: String, Codable {
        // Always restart the service
        case any
        // Never restart the service
        case none
        // Only restart the service if it fails (container stops with non-zero exit code)
        case onFailure = "on-failure"
    }
}
