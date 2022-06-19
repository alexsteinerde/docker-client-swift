import Foundation
import NIO
import NIOHTTP1
import NIOHTTP2
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
    public func execute(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: Body? = nil, deadline: NIODeadline? = nil, logger: Logger, headers: HTTPHeaders) -> EventLoopFuture<Response> {
        do {
            guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
                throw HTTPClientError.invalidURL
            }
            
            let request = try Request(url: url, method: method, headers: headers, body: body)
            return self.execute(request: request, deadline: deadline, logger: logger)
        } catch {
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }
    
    internal func executeStream(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: HTTPClientRequest.Body? = nil, timeout: TimeAmount, logger: Logger, headers: HTTPHeaders, hasLengthHeader: Bool = false) async throws -> AsyncThrowingStream<ByteBuffer, Error> {
        
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
                var collectMore = false
                var realMsgSize: UInt32 = 0
                
                for try await var buffer in body {
                    print("\n••••• executeStream() 1. readableBytes=\(buffer.readableBytes)")
                    // if we have no msg length info, we assume the buffer contains exactly 1 message.
                    if !hasLengthHeader {
                        messageBuffer = buffer
                        continuation.yield(messageBuffer)
                        continue
                    }
                    
                    if !collectMore {
                        if buffer.readableBytes == 0 {
                            continuation.finish()
                            return
                        }
                        guard let msgSize = buffer.getInteger(at: 4, endianness: .big, as: UInt32.self), msgSize > 0 else {
                            continuation.finish(
                                throwing: DockerError.corruptedData("Error reading message size in data stream having length header")
                            )
                            return
                        }
                        realMsgSize = msgSize + lengthHeaderSize
                        print("\n••••• executeStream() 2. realMsgSize=\(realMsgSize), buffer.readableBytes=\(buffer.readableBytes)")
                        messageBuffer.clear(minimumCapacity: Int(realMsgSize))
                    }
                                            
                    let readable = buffer.readableBytes
                    messageBuffer.writeBytes(buffer.readBytes(length: min(readable, Int(realMsgSize)))!)

                    
                    if messageBuffer.writerIndex < realMsgSize {
                        collectMore = true
                        print("\n••••• executeStream hasLengthHeader NEED TO COLLECT MOMORE (current=\(messageBuffer.writerIndex), msgSize=\(realMsgSize))")
                    }
                    else {
                        print("\n••••• executeStream returning final buffer with size=\(messageBuffer.writerIndex)")
                        collectMore = false
                        continuation.yield(messageBuffer)
                    }
                }
                continuation.finish()
            }
        }
    }
    
    internal func executeStream2(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: HTTPClientRequest.Body? = nil, timeout: TimeAmount, logger: Logger, headers: HTTPHeaders, hasLengthHeader: Bool = false) async throws -> AsyncThrowingStream<Data, Error> {
        
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
        return AsyncThrowingStream<Data, Error> { continuation in
            _Concurrency.Task {
                var messageBuffer = ByteBuffer()
                var availablebytes = 0
                var neededBytes = 0
                var realMsgSize: UInt32 = 0
                
                for try await var buffer in body {
                    availablebytes = buffer.readableBytes
                    guard let msgSize = buffer.getInteger(at: 4, endianness: .big, as: UInt32.self), msgSize > 0 else {
                        continuation.finish(
                            throwing: DockerError.corruptedData("Error reading message size in data stream having length header")
                        )
                        return
                    }
                    neededBytes = Int(msgSize)
                }
                continuation.finish()
            }
        }
    }
}
