import Foundation

public enum DockerScope: String, Codable {
    /// machine level
    case local
    /// cluster-wide
    case global, swarm
}
