import NIO
import NIOHTTP1
import Foundation

class GetContainerLogsEndpoint: StreamingEndpoint {
    typealias Body = NoBody
    typealias Response = AsyncThrowingStream<ByteBuffer, Error>
    
    var method: HTTPMethod = .GET
    
    private let containerId: String
    let follow: Bool
    let tail: String
    let stdout: Bool
    let stderr: Bool
    let timestamps: Bool
    let since: Int64
    let until: Int64
    
    var path: String {
        """
        containers/\(containerId)/logs\
        ?stdout=\(stdout)\
        &stderr=\(stderr)\
        &follow=\(follow)\
        &tail=\(tail)\
        &timestamps=\(timestamps)\
        &since=\(since)\
        &until=\(until)
        """
    }
    
    static var formatter: DateFormatter {
        let format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    
    init(containerId: String, stdout: Bool, stderr: Bool, timestamps: Bool, follow: Bool, tail: String, since: Date, until: Date) {
        self.containerId = containerId
        self.stdout = stdout
        self.stderr = stderr
        self.timestamps = timestamps
        self.follow = follow
        self.tail = tail
        // TODO: looks like Swift adds an extra zero compared to `docker logs --since=xxx`
        self.since = (since == .distantPast) ? 0 : Int64(since.timeIntervalSince1970)
        self.until = Int64(until.timeIntervalSince1970)
    }
    
    func map(response: Response, tty: Bool) async throws -> AsyncThrowingStream<DockerLogEntry, Error>  {
        return AsyncThrowingStream<DockerLogEntry, Error> { continuation in
            Task {
                for try await var buffer in response {
                    let totalDataSize = buffer.readableBytes
                    while buffer.readerIndex < totalDataSize {
                        if buffer.readableBytes == 0 {
                            continuation.finish()
                        }
                        if tty {
                            do {
                                for entry in try DockerStream.getEntryTty(buffer: &buffer, timestamps: timestamps) {
                                    continuation.yield(entry)
                                }
                            }
                            catch(let error) {
                                continuation.finish(throwing: error)
                                return
                            }
                        }
                        else {
                            do {
                                let entry = try DockerStream.getEntryNoTty(buffer: &buffer, timestamps: timestamps)
                                continuation.yield(entry)
                            }
                            catch (let error) {
                                continuation.finish(throwing: error)
                                return
                            }
                            
                        }
                    }
                }
                continuation.finish()
            }
        }
    }
}
