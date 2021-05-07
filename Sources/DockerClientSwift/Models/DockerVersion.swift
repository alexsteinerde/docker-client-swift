public struct DockerVersion {
    public let version: String
    public let architecture: String
    public let kernelVersion: String
    public let minAPIVersion: String
    public let os: String
}

extension DockerVersion: Codable {}
