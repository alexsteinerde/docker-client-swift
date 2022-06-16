import NIOHTTP1
import NIO
import Foundation

protocol Endpoint {
    associatedtype Response: Codable
    associatedtype Body: Codable
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Body? { get }
}

extension Endpoint {
    public var body: Body? {
        return nil
    }
}

protocol PipelineEndpoint: Endpoint {
    func map(data: String) throws -> Self.Response
}

protocol StreamingEndpoint {
    associatedtype Response: AsyncSequence
    associatedtype Body: Codable
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Body? { get }
}

extension StreamingEndpoint {
    public var body: Body? {
        return nil
    }
}


class JSONStreamingEndpoint<T>: StreamingEndpoint where T: Codable {
    internal init(path: String, method: HTTPMethod = .GET) {
        self.path = path
        self.method = method
    }
    
    var path: String
    
    var method: HTTPMethod = .GET
    
    typealias Response = AsyncThrowingStream<ByteBuffer, Error>
    
    typealias Body = NoBody
    
    private let decoder = JSONDecoder()
    
    func map(response: Response, as: T.Type) async throws -> AsyncThrowingStream<T, Error>  {
        return AsyncThrowingStream<T, Error> { continuation in
            Task {
                for try await var buffer in response {
                    let totalDataSize = buffer.readableBytes
                    while buffer.readerIndex < totalDataSize {
                        if buffer.readableBytes == 0 {
                            continuation.finish()
                        }
                        //let data = Data(buffer: buffer)
                        guard let data = buffer.readData(length: buffer.readableBytes) else {
                            continuation.finish(throwing: DockerLogDecodingError.dataCorrupted("Unable to read \(totalDataSize) bytes as Data"))
                            return
                        }
                        let splat = data.split(separator: 10 /* ascii code for \n */)
                        guard splat.count >= 1 else {
                            continuation.finish(throwing: DockerError.unknownResponse("Expected json terminated by line return"))
                            return
                        }
                        let model = try decoder.decode(T.self, from: splat.first!)
                        continuation.yield(model)
                    }
                }
                continuation.finish()
            }
        }
    }
}


protocol UploadEndpoint {
    associatedtype Response: AsyncSequence
    //associatedtype Body: ByteBuffer
    var path: String { get }
    var method: HTTPMethod { get }
    var body: ByteBuffer? { get }
}
