import DockerClientSwift
import Logging

extension DockerClient {
    /// Creates a new `DockerClient` instance that can be used for testing.
    /// It creates a new `Logger` with the log level `.debug` and passes it to the `DockerClient`.
    /// - Returns: Returns a `DockerClient` that is meant for testing purposes.
    static func testable() -> DockerClient {
        var logger = Logger(label: "docker-client-tests")
        logger.logLevel = .debug
        //return DockerClient(logger: logger)
        return DockerClient(deamonURL: .init(string: "http://127.0.0.1:2375")!, logger: logger)
    }
}
