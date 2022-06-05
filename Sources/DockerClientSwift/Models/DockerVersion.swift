import Foundation

public struct DockerVersion: Codable {
    public let platform: DockerPlatform
    public let components: [DockerVersionComponent]
    public let version, apiVersion, minAPIVersion, gitCommit: String
    public let goVersion, os, arch, kernelVersion: String
    public let buildTime: String
    
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
    }
}

// MARK: - Component
public struct DockerVersionComponent: Codable {
    public let name, version: String
    public let details: DockerVersionComponentDetails
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case version = "Version"
        case details = "Details"
    }
}

// MARK: - Details
public struct DockerVersionComponentDetails: Codable {
    public let apiVersion, arch, buildTime, experimental: String?
    public let gitCommit: String
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
