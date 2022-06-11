import NIO
import NIOHTTP1
import Foundation
import AsyncHTTPClient

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
                                for entry in try getEntryTty(buffer: &buffer, timestamps: timestamps) {
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
                                let entry = try getEntryNoTty(buffer: &buffer, timestamps: timestamps)
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
    
    /// Extracts a log entry/line for a container not having a TTY
    private func getEntryNoTty(buffer: inout ByteBuffer, timestamps: Bool) throws -> DockerLogEntry {
        let timestampLen = timestamps ? 31 : 0
        
        guard let sourceRaw: UInt8 = buffer.readInteger(endianness: .big, as: UInt8.self) else {
            throw DockerLogDecodingError.dataCorrupted("Unable to read log entry source stream header")
        }
        let msgSource = DockerLogEntry.Source.init(rawValue: sourceRaw) ?? .stdout
        let _ = buffer.readBytes(length: 3) // 3 unused bytes
        
        guard let msgSize: UInt32 = buffer.readInteger(endianness: .big, as: UInt32.self) else {
            throw DockerLogDecodingError.dataCorrupted("Unable to read log size header")
        }
        
        guard msgSize > 0 else {
            throw DockerLogDecodingError.noMessageFound
        }
        if buffer.readableBytes < msgSize {
            // TODO: does this happen during normal logs streaming behavior?
            throw DockerLogDecodingError.dataCorrupted("Readable bytes (\(buffer.readableBytes)) is less than msgSize (\(msgSize))")
        }
        
        var timestamp: Date? = nil
        var msgBuffer = ByteBuffer.init(bytes: buffer.readBytes(length: Int(msgSize))!)
        if timestamps {
            guard let timestampRaw = msgBuffer.readString(length: timestampLen, encoding: .utf8) else {
                throw DockerLogDecodingError.noTimestampFound
            }
            guard let timestampTry = GetContainerLogsEndpoint.formatter.date(from: String(timestampRaw)) else {
                throw DockerLogDecodingError.timestampCorrupted
            }
            timestamp = timestampTry
        }
        guard let message = msgBuffer.readString(length: msgBuffer.readableBytes - 1, encoding: .utf8) else {
            throw  DockerLogDecodingError.dataCorrupted("Unable to parse log message as String")
        }
        
        return DockerLogEntry(source: msgSource, timestamp: timestamp, message: message)
    }
    
    /// Extracts a log entry/line for a container having a TTY
    private func getEntryTty(buffer: inout ByteBuffer, timestamps: Bool) throws -> [DockerLogEntry] {
        let timestampLen = timestamps ? 31 : 0
        var logEntries: [DockerLogEntry] = []
        
        let data = buffer.readData(length: buffer.readableBytes)!
        let lines = data.split(separator: 10 /* ascii code for \n */)
        for line in lines {
            var timestamp: Date? = nil
            var msgBuffer = ByteBuffer(data: line)
            if timestamps {
                guard let timestampRaw = msgBuffer.readString(length: timestampLen, encoding: .utf8) else {
                    throw DockerLogDecodingError.noTimestampFound
                }
                guard let timestampTry = GetContainerLogsEndpoint.formatter.date(from: String(timestampRaw)) else {
                    throw DockerLogDecodingError.timestampCorrupted
                }
                timestamp = timestampTry
            }
            guard let message = msgBuffer.readString(length: msgBuffer.readableBytes - 1, encoding: .utf8) else {
                throw  DockerLogDecodingError.dataCorrupted("Unable to parse log message as String")
            }
            
            logEntries.append(
                DockerLogEntry(source: .stdout, timestamp: timestamp, message: message)
            )
        }
        return logEntries
    }
}
