import Foundation

public struct DockerVersion: Codable {
    let platform: Platform
    let components: [Component]
    let version, apiVersion, minAPIVersion, gitCommit: String
    let goVersion, os, arch, kernelVersion: String
    let buildTime: String
    
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
struct Component: Codable {
    let name, version: String
    let details: Details
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case version = "Version"
        case details = "Details"
    }
}

// MARK: - Details
struct Details: Codable {
    let apiVersion, arch, buildTime, experimental: String?
    let gitCommit: String
    let goVersion, kernelVersion, minAPIVersion, os: String?
    
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
struct Platform: Codable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
    }
}
