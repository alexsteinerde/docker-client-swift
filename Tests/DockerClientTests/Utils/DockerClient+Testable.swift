import DockerClientSwift
import Logging
import NIOSSL

extension DockerClient {
    /// Creates a new `DockerClient` instance that can be used for testing.
    /// It creates a new `Logger` with the log level `.debug` and passes it to the `DockerClient`.
    /// - Returns: Returns a `DockerClient` that is meant for testing purposes.
    static func testable() -> DockerClient {
        var logger = Logger(label: "docker-client-tests")
        logger.logLevel = .debug
        // Local Unix socket
        //return DockerClient(logger: logger)
        
        // Remote via simple HTTP
        //return DockerClient(deamonURL: .init(string: "http://127.0.0.1:2375")!, logger: logger)
        
        // Remote daemon, using HTTPS and client certs authentication
        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        tlsConfig.privateKey = NIOSSLPrivateKeySource.file("client-key.pem")
        tlsConfig.certificateChain.append(NIOSSLCertificateSource.file("client-certificate.pem"))
        tlsConfig.additionalTrustRoots.append(.file("ca-public.pem"))
        tlsConfig.certificateVerification = .noHostnameVerification
        return DockerClient(
            deamonURL: .init(string: "https://51.15.19.7:2376")!,
            tlsConfig: tlsConfig,
            logger: logger
        )
    }
}
