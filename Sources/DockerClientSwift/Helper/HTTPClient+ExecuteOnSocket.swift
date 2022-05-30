import Foundation
import NIO
import NIOHTTP1
import NIOSSL
import AsyncHTTPClient
import Logging

extension HTTPClient {
    /// Executes a HTTP request on a socket.
    /// - Parameters:
    ///   - method: HTTP method.
    ///   - socketPath: The path to the unix domain socket to connect to.
    ///   - urlPath: The URI path and query that will be sent to the server.
    ///   - body: Request body.
    ///   - deadline: Point in time by which the request must complete.
    ///   - logger: The logger to use for this request.
    ///   - headers: Custom HTTP headers.
    /// - Returns: Returns an `EventLoopFuture` with the `Response` of the request
    public func execute(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: Body? = nil, tlsConfig: TLSConfiguration?, deadline: NIODeadline? = nil, logger: Logger, headers: HTTPHeaders) -> EventLoopFuture<Response> {
        do {
            var url: URL //(httpURLWithSocketPath: daemonURL.absoluteString, uri: urlPath)
            if daemonURL.scheme == "http+unix" {
                guard let socketURL = URL(httpURLWithSocketPath: daemonURL.absoluteString, uri: urlPath) else {
                    throw HTTPClientError.invalidURL
                }
                url = socketURL
            }
            else {
                url = daemonURL.appendingPathComponent(urlPath)
            }
            
            print("••• URL=\(url.description)\n")
            let request = try Request(url: url, method: method, headers: headers, body: body, tlsConfiguration: tlsConfig)
            return self.execute(request: request, deadline: deadline, logger: logger)
        } catch {
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }
    /*public func execute(_ method: HTTPMethod = .GET, socketPath: String, urlPath: String, body: Body? = nil, tlsConfig: TLSConfiguration?, deadline: NIODeadline? = nil, logger: Logger, headers: HTTPHeaders) -> EventLoopFuture<Response> {
        do {
            guard let url = URL(httpURLWithSocketPath: socketPath, uri: urlPath) else {
                throw HTTPClientError.invalidURL
            }
            let request = try Request(url: url, method: method, headers: headers, body: body, tlsConfiguration: tlsConfig)
            return self.execute(request: request, deadline: deadline, logger: logger)
        } catch {
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }*/
}
