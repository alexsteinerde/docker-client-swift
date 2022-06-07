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
        ("Accept", "application/json;charset=utf-8"),
        ("Content-Type", "application/json"),
        ("Host", "localhost")
    ])
    private let decoder: JSONDecoder
    
    private let deamonURL: URL
    private let tlsConfig: TLSConfiguration?
    private let client: HTTPClient
    private let logger: Logger
    
    /// Initialize the `DockerClient`.
    /// - Parameters:
    ///   - daemonURL: The URL where the Docker API is listening on. Default is `http+unix:///var/run/docker.sock`.
    ///   - client: `HTTPClient` instance that is used to execute the requests. Default is `.init(eventLoopGroupProvider: .createNew)`.
    ///   - tlsConfig: `TLSConfiguration` for a Docker daemon requiring TLS authentication. Default is `nil`.
    ///   - logger: `Logger` for the `DockerClient`. Default is `.init(label: "docker-client")`.
    public init(
        deamonURL: URL = URL(httpURLWithSocketPath: "/var/run/docker.sock")!,
        client: HTTPClient = .init(eventLoopGroupProvider: .createNew),
        tlsConfig: TLSConfiguration? = nil,
        logger: Logger = .init(label: "docker-client")) {
            
        self.deamonURL = deamonURL
        self.tlsConfig = tlsConfig
        self.client = client
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
    
    /// Executes a request to a specific endpoint. The `Endpoint` struct provides all necessary data and parameters for the request.
    /// - Parameter endpoint: `Endpoint` instance with all necessary data and parameters.
    /// - Throws: It can throw an error when encoding the body of the `Endpoint` request to JSON.
    /// - Returns: Returns the expected result definied by the `Endpoint`.
    @discardableResult
    internal func run<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        logger.trace("\(Self.self) execute Endpoint: \(endpoint.path)")
        return try await client.execute(
            endpoint.method,
            daemonURL: self.deamonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())},
            tlsConfig: self.tlsConfig,
            logger: logger,
            headers: self.headers
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
        logger.trace("\(Self.self) execute PipelineEndpoint: \(endpoint.path)")
        return try await client.execute(
            endpoint.method,
            daemonURL: self.deamonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())},
            tlsConfig: self.tlsConfig,
            logger: logger,
            headers: self.headers
        )
        .logResponseBody(logger)
        .mapString(map: endpoint.map(data: ))
        .get()
    }
    
    @discardableResult
    internal func run<T: StreamingEndpoint>(_ endpoint: T, timeout: TimeAmount) async throws -> T.Response {
        logger.debug("\(Self.self) execute StreamingEndpoint: \(endpoint.path)")
        let stream = try await client.executeStream(
            endpoint.method,
            daemonURL: self.deamonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            //body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())},
            body: endpoint.body.map {
                HTTPClientRequest.Body.bytes( try! $0.encode())
            },
            tlsConfig: self.tlsConfig,
            timeout: timeout,
            logger: logger,
            headers: self.headers
        )
        return stream as! T.Response
    }
}
