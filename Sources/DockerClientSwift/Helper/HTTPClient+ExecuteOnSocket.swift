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
        
        let lengthHeaderSize: UInt32 = 8
        let response = try await self.execute(request, timeout: timeout, logger: logger)
        let body = response.body
        return AsyncThrowingStream<ByteBuffer, Error> { continuation in
            _Concurrency.Task {
                var messageBuffer = ByteBuffer()
                //var iterator = body.makeAsyncIterator()
                var collectMore = false
                var realMsgSize: UInt32 = 0
                for try await var buffer in body {
                    if hasLengthHeader {
                        if !collectMore {
                            messageBuffer.clear(minimumCapacity: realMsgSize)
                            guard let msgSize = buffer.getInteger(at: 4, endianness: .big, as: UInt32.self), msgSize > 0 else {
                                continuation.finish(
                                    throwing: DockerError.corruptedData("Error reading message size in a data stream having length header")
                                )
                                return
                            }
                            realMsgSize = msgSize + lengthHeaderSize
                        }
                                                
                        messageBuffer.writeBuffer(&buffer)
                        if messageBuffer.writerIndex < realMsgSize {
                            collectMore = true
                        }
                        else {
                            print("\n••••• executeStream hasLengthHeader tries to collect \(realMsgSize) bytes, final buffer index=\(messageBuffer.writerIndex)")
                            continuation.yield(messageBuffer)
                        }
                    }
                    else {
                        messageBuffer = buffer
                        continuation.yield(messageBuffer)
                    }
                    
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
