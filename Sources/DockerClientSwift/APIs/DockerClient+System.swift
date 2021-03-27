import NIO

extension DockerClient {
    /// Get the version of the Docker runtime.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns an `EventLoopFuture` of the `DockerVersion`.
    public func version() throws -> EventLoopFuture<DockerVersion> {
        try run(VersionEndpoint())
            .map({ response in
                DockerVersion(version: response.version, architecture: response.arch, kernelVersion: response.kernelVersion, minAPIVersion: response.minAPIVersion, os: response.os)
            })
    }
}
