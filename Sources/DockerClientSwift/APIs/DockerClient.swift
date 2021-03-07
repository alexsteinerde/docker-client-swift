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
    
    public init(daemonSocket: String = "/var/run/docker.sock", client: HTTPClient = .init(eventLoopGroupProvider: .createNew), logger: Logger = .init(label: "docker-client")) {
        self.daemonSocket = daemonSocket
        self.client = client
        self.logger = logger
    }
    
    deinit {
        try? client.syncShutdown()
    }

    func run<T: Endpoint>(_ endpoint: T) throws -> EventLoopFuture<T.Response> {
        logger.info("Execute Endpoint: \(endpoint.path)")
        return client.execute(endpoint.method, socketPath: daemonSocket, urlPath: "/v1.40/\(endpoint.path)", body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())}, logger: logger, headers: HTTPHeaders([("Content-Type", "application/json")]))
            .logResponseBody(logger)
            .decode(as: T.Response.self)
    }
    
    func run<T: PipelineEndpoint>(_ endpoint: T) throws -> EventLoopFuture<T.Response> {
        logger.info("Execute PipelineEndpoint: \(endpoint.path)")
        return client.execute(endpoint.method, socketPath: daemonSocket, urlPath: "/v1.40/\(endpoint.path)", body: try endpoint.body.map({ HTTPClient.Body.data( try $0.encode()) }))
            .logResponseBody(logger)
            .mapString(map: endpoint.map(data: ))
    }
}
