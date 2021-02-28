import NIO

extension DockerClient {
    public func version() throws -> EventLoopFuture<DockerVersion> {
        try run(VersionEndpoint())
            .map({ response in
                DockerVersion(version: response.version, architecture: response.arch, kernelVersion: response.kernelVersion, minAPIVersion: response.minAPIVersion, os: response.os)
            })
    }
}
