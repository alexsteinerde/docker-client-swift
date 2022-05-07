import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient
import Logging

/// The entry point for docker client commands. 
public class DockerClient {
    private let daemonSocket: String
    private let client: HTTPClient
    private let logger: Logger
    
    /// Initialize the `DockerClient`.
    /// - Parameters:
    ///   - daemonSocket: The socket path where the Docker API is listening on. Default is `/var/run/docker.sock`.
    ///   - client: `HTTPClient` instance that is used to execute the requests. Default is `.init(eventLoopGroupProvider: .createNew)`.
    ///   - logger: `Logger` for the `DockerClient`. Default is `.init(label: "docker-client")`.
    public init(daemonSocket: String = "/var/run/docker.sock", client: HTTPClient = .init(eventLoopGroupProvider: .createNew), logger: Logger = .init(label: "docker-client")) {
        self.daemonSocket = daemonSocket
        self.client = client
        self.logger = logger
    }
    
    /// The client needs to be shutdown otherwise it can crash on exit.
    /// - Throws: Throws an error if the `HTTPClient` can not be shutdown.
    public func syncShutdown() throws {
        try client.syncShutdown()
    }
    
    /// Executes a request to a specific endpoint. The `Endpoint` struct provides all necessary data and parameters for the request.
    /// - Parameter endpoint: `Endpoint` instance with all necessary data and parameters.
    /// - Throws: It can throw an error when encoding the body of the `Endpoint` request to JSON.
    /// - Returns: Returns an `EventLoopFuture` of the expected result definied by the `Endpoint`.
    internal func run<T: Endpoint>(_ endpoint: T) throws -> EventLoopFuture<T.Response> {
        logger.info("Execute Endpoint: \(endpoint.path)")
        return client.execute(endpoint.method, socketPath: daemonSocket, urlPath: "/v1.40/\(endpoint.path)", body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())}, logger: logger, headers: HTTPHeaders([("Content-Type", "application/json"), ("Host", "localhost")]))
            .logResponseBody(logger)
            .decode(as: T.Response.self)
    }
    
    /// Executes a request to a specific endpoint. The `PipelineEndpoint` struct provides all necessary data and parameters for the request. The difference for between `Endpoint` and `EndpointPipeline` is that the second one needs to provide a function that transforms the response as a `String` to the expected result.
    /// - Parameter endpoint: `PipelineEndpoint` instance with all necessary data and parameters.
    /// - Throws: It can throw an error when encoding the body of the `PipelineEndpoint` request to JSON.
    /// - Returns: Returns an `EventLoopFuture` of the expected result definied and transformed by the `PipelineEndpoint`.
    internal func run<T: PipelineEndpoint>(_ endpoint: T) throws -> EventLoopFuture<T.Response> {
        logger.info("Execute PipelineEndpoint: \(endpoint.path)")
        return client.execute(endpoint.method, socketPath: daemonSocket, urlPath: "/v1.40/\(endpoint.path)", body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())}, logger: logger, headers: HTTPHeaders([("Content-Type", "application/json"), ("Host", "localhost")]))
            .logResponseBody(logger)
            .mapString(map: endpoint.map(data: ))
    }
}
