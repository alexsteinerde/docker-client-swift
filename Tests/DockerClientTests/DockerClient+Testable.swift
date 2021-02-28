import DockerClient
import Logging

extension DockerClient {
    static func testable() -> DockerClient {
        var logger = Logger(label: "docker-client-tests")
        logger.logLevel = .debug
        return DockerClient(logger: logger)
    }
}
