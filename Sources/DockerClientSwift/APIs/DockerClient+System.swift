import NIO

extension DockerClient {
    
    /// Get system information
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns the `SystemInformation`.
    public func info() async throws -> SystemInformation {
        return try await run(SystemInformationEndpoint())
    }
    
    /// Endpoint you can use to test if the Docker server is accessible.
    public func ping() async throws {
        let ping = try await run(PingEndpoint())
        guard ping == "OK" else {
            throw DockerError.unknownResponse(ping)
        }
    }
    
    /// Get the version of the Docker runtime.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns the `DockerVersion`.
    public func version() async throws -> DockerVersion {
        return try await run(VersionEndpoint())
    }
    
    /// Get data usage information.
    /// - Throws: Errors that can occur when executing the request.
    /// - Returns: Returns the `DataUsageInformation`.
    public func dataUsage() async throws -> DataUsageInformation {
        return try await run(DiskUsageInformationEndpoint())
    }
    
    public func events() async throws -> AsyncThrowingStream<DockerEvent, Error> {
        let endpoint = JSONStreamingEndpoint<DockerEvent>(path: "/events")
        let stream = try await run(endpoint, timeout: .hours(12), hasLengthHeader: false)
        return try await endpoint.map(response: stream, as: DockerEvent.self)
    }
}
