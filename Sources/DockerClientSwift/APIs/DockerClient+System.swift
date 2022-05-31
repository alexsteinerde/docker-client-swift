import NIO

extension DockerClient {
    /// Get the version of the Docker runtime.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns the `DockerVersion`.
    public func version() async throws -> DockerVersion {
        let response = try await run(VersionEndpoint())
        return DockerVersion(
            version: response.version,
            architecture: response.arch,
            kernelVersion: response.kernelVersion,
            minAPIVersion: response.minAPIVersion,
            os: response.os
        )
    }
}
