import Foundation
import NIO
import NIOHTTP1
import NIOSSL
import AsyncHTTPClient
import Logging

/// The entry point for Docker client commands.
public class DockerClient {
    private let apiVersion = "v1.41"
    private let headers = HTTPHeaders([
        ("Host", "localhost"), // Required by Docker
        ("Accept", "application/json;charset=utf-8"),
        ("Content-Type", "application/json")
    ])
    private let decoder: JSONDecoder
    
    private let deamonURL: URL
    private let tlsConfig: TLSConfiguration?
    private let client: HTTPClient
    private let logger: Logger
    
    
    /// Initialize the `DockerClient`.
    /// - Parameters:
    ///   - daemonURL: The URL where the Docker API is listening on. Default is `http+unix:///var/run/docker.sock`.
    ///   - tlsConfig: `TLSConfiguration` for a Docker daemon requiring TLS authentication. Default is `nil`.
    ///   - logger: `Logger` for the `DockerClient`. Default is `.init(label: "docker-client")`.
    ///   - clientThreads: Number of threads to use for the HTTP client EventLoopGroup. Defaults to 2.
    ///   - timeout: Pass custom connect and read timeouts via a `HTTPClient.Configuration.Timeout` instance
    ///   - proxy: Proxy settings, defaults to `nil`.
    public init(
        deamonURL: URL = URL(httpURLWithSocketPath: "/var/run/docker.sock")!,
        tlsConfig: TLSConfiguration? = nil,
        logger: Logger = .init(label: "docker-client"),
        clientThreads: Int = 2,
        timeout: HTTPClient.Configuration.Timeout = .init(),
        proxy: HTTPClient.Configuration.Proxy? = nil
    ) {
            
            self.deamonURL = deamonURL
            self.tlsConfig = tlsConfig
            let clientConfig = HTTPClient.Configuration(
                tlsConfiguration: tlsConfig,
                timeout: timeout,
                proxy: proxy,
                ignoreUncleanSSLShutdown: true
            )
            let httpClient = HTTPClient(
                eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup(numberOfThreads: clientThreads)),
                configuration: clientConfig
            )
            self.client = httpClient
            self.logger = logger
            
            // Docker uses a slightly custom format for returning dates
            let format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
            let formatter = DateFormatter()
            formatter.dateFormat = format
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(formatter)
            self.decoder = decoder
        }
    
    /// The client needs to be shutdown otherwise it can crash on exit.
    /// - Throws: Throws an error if the `HTTPClient` can not be shutdown.
    public func syncShutdown() throws {
        try client.syncShutdown()
    }
    
    /// The client needs to be shutdown otherwise it can crash on exit.
    /// - Throws: Throws an error if the `HTTPClient` can not be shutdown.
    public func shutdown() async throws {
        try await client.shutdown()
    }
    
    /// Executes a request to a specific endpoint. The `Endpoint` struct provides all necessary data and parameters for the request.
    /// - Parameter endpoint: `Endpoint` instance with all necessary data and parameters.
    /// - Throws: It can throw an error when encoding the body of the `Endpoint` request to JSON.
    /// - Returns: Returns the expected result definied by the `Endpoint`.
    @discardableResult
    internal func run<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        logger.debug("\(Self.self) execute Endpoint: \(endpoint.path)")
        var finalHeaders: HTTPHeaders = self.headers
        if let additionalHeaders = endpoint.headers {
            finalHeaders.add(contentsOf: additionalHeaders)
        }
        return try await client.execute(
            endpoint.method,
            daemonURL: self.deamonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())},
            logger: logger,
            headers: finalHeaders
        )
        .logResponseBody(logger)
        .decode(as: T.Response.self, decoder: self.decoder)
        .get()
    }
    
    /// Executes a request to a specific endpoint. The `PipelineEndpoint` struct provides all necessary data and parameters for the request.
    /// The difference for between `Endpoint` and `EndpointPipeline` is that the second one needs to provide a function that transforms the response as a `String` to the expected result.
    /// - Parameter endpoint: `PipelineEndpoint` instance with all necessary data and parameters.
    /// - Throws: It can throw an error when encoding the body of the `PipelineEndpoint` request to JSON.
    /// - Returns: Returns the expected result definied and transformed by the `PipelineEndpoint`.
    @discardableResult
    internal func run<T: PipelineEndpoint>(_ endpoint: T) async throws -> T.Response {
        logger.debug("\(Self.self) execute PipelineEndpoint: \(endpoint.path)")
        return try await client.execute(
            endpoint.method,
            daemonURL: self.deamonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())},
            logger: logger,
            headers: self.headers
        )
        .logResponseBody(logger)
        .mapString(map: endpoint.map(data: ))
        .get()
    }
    
    @discardableResult
    internal func run<T: StreamingEndpoint>(_ endpoint: T, timeout: TimeAmount, hasLengthHeader: Bool) async throws -> T.Response {
        logger.debug("\(Self.self) execute StreamingEndpoint: \(endpoint.path)")
        let stream = try await client.executeStream(
            endpoint.method,
            daemonURL: self.deamonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body.map {
                HTTPClientRequest.Body.bytes( try! $0.encode())
            },
            timeout: timeout,
            logger: logger,
            headers: self.headers,
            hasLengthHeader: hasLengthHeader
        )
        return stream as! T.Response
    }
    
    @discardableResult
    internal func run<T: UploadEndpoint>(_ endpoint: T, timeout: TimeAmount) async throws -> T.Response {
        logger.debug("\(Self.self) execute \(T.self): \(endpoint.path)")
        let stream = try await client.executeStream(
            endpoint.method,
            daemonURL: self.deamonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body == nil ? nil : .bytes(endpoint.body!),
            timeout: timeout,
            logger: logger,
            headers: self.headers
        )
        return stream as! T.Response
    }
}
