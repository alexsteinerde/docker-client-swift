import Foundation
import BetterCodable

public struct DockerVersion: Codable {
    
    public let platform: DockerPlatform
    
    /// Information about system components
    public let components: [DockerVersionComponent]
    
    /// The version of the daemon
    public let version: String
    
    /// The default (and highest) API version that is supported by the daemon
    public let apiVersion: String
    
    /// The minimum API version that is supported by the daemon
    public let minAPIVersion: String
    
    /// The Git commit of the source code that was used to build the daemon
    public let gitCommit: String
    
    /// The version Go used to compile the daemon, and the version of the Go runtime in use.
    public let goVersion: String
    
    /// The operating system that the daemon is running on ("linux" or "windows")
    public let os: String
    
    /// The CPU  architecture that the daemon is running on
    public let arch: String
    
    /// The kernel version (uname -r) that the daemon is running on.
    public let kernelVersion: String?
    
    /// The date and time that the daemon was compiled.
    @DateValue<ISO8601WithFractionalSecondsStrategy>
    private(set) public var buildTime: Date
    
    /// Indicates if the daemon is started with experimental features enabled.
    /// This field is omitted when empty / false.
    public let experimental: Bool?
    
    enum CodingKeys: String, CodingKey {
        case platform = "Platform"
        case components = "Components"
        case version = "Version"
        case apiVersion = "ApiVersion"
        case minAPIVersion = "MinAPIVersion"
        case gitCommit = "GitCommit"
        case goVersion = "GoVersion"
        case os = "Os"
        case arch = "Arch"
        case kernelVersion = "KernelVersion"
        case buildTime = "BuildTime"
        case experimental = "Experimental"
    }
}

// MARK: - Component
public struct DockerVersionComponent: Codable {
    public let name, version: String
    public let details: DockerVersionComponentDetails?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case version = "Version"
        case details = "Details"
    }
}

// MARK: - Details
public struct DockerVersionComponentDetails: Codable {
    public let apiVersion, arch: String?
    
    // This is a boolean, but encoded as a String
    public let experimental: String?
    
    // This is a Date but is not encoded using the format used elsewhere in the Docker API.
    public let buildTime: String?
    
    public let gitCommit: String?
    public let goVersion, kernelVersion, minAPIVersion, os: String?
    
    enum CodingKeys: String, CodingKey {
        case apiVersion = "ApiVersion"
        case arch = "Arch"
        case buildTime = "BuildTime"
        case experimental = "Experimental"
        case gitCommit = "GitCommit"
        case goVersion = "GoVersion"
        case kernelVersion = "KernelVersion"
        case minAPIVersion = "MinAPIVersion"
        case os = "Os"
    }
}

// MARK: - Platform
public struct DockerPlatform: Codable {
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
    }
}
