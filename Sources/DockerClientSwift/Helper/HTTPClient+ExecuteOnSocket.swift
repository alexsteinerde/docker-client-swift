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
            guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
                throw HTTPClientError.invalidURL
            }
            
            let request = try Request(url: url, method: method, headers: headers, body: body, tlsConfiguration: tlsConfig)
            return self.execute(request: request, deadline: deadline, logger: logger)
        } catch {
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }
    
    internal func executeStream(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: HTTPClientRequest.Body? = nil, tlsConfig: TLSConfiguration?, timeout: TimeAmount, logger: Logger, headers: HTTPHeaders, hasLengthHeader: Bool = false) async throws -> AsyncThrowingStream<ByteBuffer, Error> {
        
        guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
            throw HTTPClientError.invalidURL
        }
        
        var request = HTTPClientRequest(url: url.absoluteString)
        request.headers = headers
        request.method = method
        request.body = body
        
        let lengthHeaderSize = 8
        let response = try await self.execute(request, timeout: timeout, logger: logger)
        let body = response.body
        return AsyncThrowingStream<ByteBuffer, Error> { continuation in
            _Concurrency.Task {
                var messageBuffer = ByteBuffer()
                for try await var buffer in body {
                    //var msgSize = buffer.readableBytes
                    if hasLengthHeader {
                        guard let realMsgSize = buffer.getInteger(at: 4, endianness: .big, as: Int.self) else {
                            continuation.finish(
                                throwing: DockerError.corruptedData("Error reading message size in a data stream having length header")
                            )
                            return
                        }
                        messageBuffer.clear(minimumCapacity: realMsgSize)
                        try await body.collect(upTo: realMsgSize + lengthHeaderSize, into: &messageBuffer)
                        //buffer.copyBytes(at: 0, to: buffer.readableBytes, length: 3)
                        //messageBuffer.writeBuffer(&buffer)
                        //while messageBuffer.writerIndex < realMsgSize + lengthHeaderSize {
                        //    body.
                        //}
                    }
                    else {
                        messageBuffer = buffer
                    }
                    continuation.yield(messageBuffer)
                }
                continuation.finish()
            }
        }
    }
    
    
    /*public func execute(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: Body? = nil, tlsConfig: TLSConfiguration?, deadline: NIODeadline? = nil, logger: Logger, headers: HTTPHeaders) async throws -> Response {
        guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
            throw HTTPClientError.invalidURL
        }
        
        let request = try Request(url: url, method: method, headers: headers, body: body, tlsConfiguration: tlsConfig)
        return try await self.execute(request: request, deadline: deadline, logger: logger).get()
        
    }*/
}
